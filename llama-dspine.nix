{ pkgs, llamaCuda }:

# CUDA llama.cpp 0.8.0 with two patches:
# - the DSpine drafter, backported from the newer fork (runtime only);
# - llama-offload-speedups.patch, for a model that mostly lives in RAM: host
#   weights are streamed to the GPU through a VRAM ring ahead of use, prompt
#   ubatches skip the recurrent rollback snapshots, a checkpoint replay carries
#   a new draft, and the prompt tail is split once instead of three times.
# The second patch touches GGML and the server, so the whole package is rebuilt.
assert llamaCuda.version == "0.8.0";
let
  baseRevision = "8642541b255bfb5dc39cd351a178be09013a55d6";
  dspineRevision = "d493f841b20241606c47a4e0537d3c786b5cf50b";

  # Vendored here so this expression is self-contained, including outside a flake.
  # Patch SHA-256: 02e6deb1174879b1057caaa263987166fa0be82c383af37dedf24cdf9a9413b5
  runtimePatch = pkgs.writeText "dspine-v0.8.0.patch" ''
    # Runtime-only DSpine backport
    # Base: ggml-org/llama.cpp 8642541b255bfb5dc39cd351a178be09013a55d6 (v0.8.0)
    # Origin: Ajay9o9/llama.cpp d493f841b20241606c47a4e0537d3c786b5cf50b
    # Parent: a691b2345844ce1b430201fc5fd404ce062e05f2
    # Changes: drop conversion-only Python hunks; relocate quantization exclusion
    # after GLM5_NEXT because v0.8.0 has no KIMI_K31 block. Other additions unchanged.
    # Public include/llama.h and all GGML sources/headers remain untouched.
    
    diff --git a/src/llama-arch.cpp b/src/llama-arch.cpp
    --- a/src/llama-arch.cpp
    +++ b/src/llama-arch.cpp
    @@ -807,6 +807,12 @@
         { LLM_TENSOR_DFLASH_SELECTOR_PREV,                   "selector_predecessor" },
         { LLM_TENSOR_DFLASH_SELECTOR_NEXT,                   "selector_successor" },
         { LLM_TENSOR_DFLASH_SELECTOR_HIDDEN,                 "selector_hidden" },
    +    { LLM_TENSOR_DSPINE_CODEBOOK,                        "dspine_codebook" },
    +    { LLM_TENSOR_DSPINE_GATE,                            "dspine_gate" },
    +    { LLM_TENSOR_DSPINE_PRED_GATE,                       "dspine_pred_gate" },
    +    { LLM_TENSOR_DSPINE_PREV,                            "dspine_prev" },
    +    { LLM_TENSOR_DSPINE_READ,                            "blk.%d.dspine_read" },
    +    { LLM_TENSOR_DSPINE_WRITE,                           "blk.%d.dspine_write" },
         { LLM_TENSOR_LILICORR_TOKEN_PROJ,                    "lilicorr.token_proj" },
         { LLM_TENSOR_LILICORR_PASS_HIDDEN_PROJ,              "lilicorr.pass_hidden_proj" },
         { LLM_TENSOR_LILICORR_SLOT_EMBD,                     "lilicorr.slot_embedding" },
    @@ -1151,6 +1157,12 @@
         {LLM_TENSOR_DFLASH_SELECTOR_PREV,       {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_GET_ROWS}},
         {LLM_TENSOR_DFLASH_SELECTOR_NEXT,       {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_GET_ROWS}},
         {LLM_TENSOR_DFLASH_SELECTOR_HIDDEN,     {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
    +    {LLM_TENSOR_DSPINE_CODEBOOK,            {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_GET_ROWS}},
    +    {LLM_TENSOR_DSPINE_GATE,                {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
    +    {LLM_TENSOR_DSPINE_PRED_GATE,           {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
    +    {LLM_TENSOR_DSPINE_PREV,                {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
    +    {LLM_TENSOR_DSPINE_READ,                {LLM_TENSOR_LAYER_REPEATING, GGML_OP_MUL_MAT}},
    +    {LLM_TENSOR_DSPINE_WRITE,               {LLM_TENSOR_LAYER_REPEATING, GGML_OP_MUL_MAT}},
         {LLM_TENSOR_LILICORR_TOKEN_PROJ,        {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
         {LLM_TENSOR_LILICORR_PASS_HIDDEN_PROJ,  {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_MUL_MAT}},
         {LLM_TENSOR_LILICORR_SLOT_EMBD,         {LLM_TENSOR_LAYER_OUTPUT,    GGML_OP_ADD}},
    diff --git a/src/llama-arch.h b/src/llama-arch.h
    --- a/src/llama-arch.h
    +++ b/src/llama-arch.h
    @@ -812,6 +812,12 @@
         LLM_TENSOR_DFLASH_SELECTOR_PREV,
         LLM_TENSOR_DFLASH_SELECTOR_NEXT,
         LLM_TENSOR_DFLASH_SELECTOR_HIDDEN,
    +    LLM_TENSOR_DSPINE_CODEBOOK,
    +    LLM_TENSOR_DSPINE_GATE,
    +    LLM_TENSOR_DSPINE_PRED_GATE,
    +    LLM_TENSOR_DSPINE_PREV,
    +    LLM_TENSOR_DSPINE_READ,
    +    LLM_TENSOR_DSPINE_WRITE,
         LLM_TENSOR_LILICORR_TOKEN_PROJ,
         LLM_TENSOR_LILICORR_PASS_HIDDEN_PROJ,
         LLM_TENSOR_LILICORR_SLOT_EMBD,
    diff --git a/src/llama-model.h b/src/llama-model.h
    --- a/src/llama-model.h
    +++ b/src/llama-model.h
    @@ -401,6 +401,9 @@
         struct ggml_tensor * dflash_ffn_conv_base  = nullptr;
         struct ggml_tensor * dflash_ffn_conv_proj  = nullptr;
     
    +    struct ggml_tensor * dspine_read  = nullptr;
    +    struct ggml_tensor * dspine_write = nullptr;
    +
         struct ggml_tensor * lilicorr_attn_norm       = nullptr;
         struct ggml_tensor * lilicorr_mlp_norm        = nullptr;
         struct ggml_tensor * lilicorr_attn_in_proj    = nullptr;
    @@ -806,6 +809,13 @@
         struct ggml_tensor * dflash_selector_next   = nullptr;
         struct ggml_tensor * dflash_selector_hidden = nullptr;
     
    +    // DSpine code bridge
    +    struct ggml_tensor * dspine_codebook  = nullptr;
    +    struct ggml_tensor * dspine_gate      = nullptr;
    +    struct ggml_tensor * dspine_gate_b    = nullptr;
    +    struct ggml_tensor * dspine_pred_gate = nullptr;
    +    struct ggml_tensor * dspine_prev      = nullptr;
    +
         struct ggml_tensor * lilicorr_token_proj          = nullptr;
         struct ggml_tensor * lilicorr_token_proj_b        = nullptr;
         struct ggml_tensor * lilicorr_token_proj_s        = nullptr;
    diff --git a/src/llama-quant.cpp b/src/llama-quant.cpp
    --- a/src/llama-quant.cpp
    +++ b/src/llama-quant.cpp
    @@ -372,6 +372,11 @@
             quantize &= name.find("attn_v_b.weight")         == std::string::npos;
         }
     
    +    // dspine: the code bridge projections are small and steer every draft row, keep them accurate
    +    if (arch == LLM_ARCH_DFLASH) {
    +        quantize &= name.find("dspine_") == std::string::npos || name.find("dspine_codebook") != std::string::npos;
    +    }
    +
         // the decision head of vllm-decision2 is small and computed in F32
         if (arch == LLM_ARCH_VLLM_DECISION2) {
             quantize &= name.compare(0, 9, "decision.") != 0;
    diff --git a/src/models/dflash.cpp b/src/models/dflash.cpp
    --- a/src/models/dflash.cpp
    +++ b/src/models/dflash.cpp
    @@ -341,6 +341,31 @@
                 layer.dflash_ffn_conv_proj  = create_tensor(tn(LLM_TENSOR_DFLASH_FFN_CONV_PROJ,  "weight", i), { n_embd, projected }, 0);
             }
         }
    +
    +    // DSpine: code bridge after every layer, its last write is refined over the top-k lattice
    +    const struct ggml_tensor * dspine_codebook_meta = ml->get_tensor_meta("dspine_codebook.weight");
    +    const struct ggml_tensor * dspine_gate_meta     = ml->get_tensor_meta("dspine_gate.weight");
    +    if (dspine_codebook_meta && dspine_gate_meta) {
    +        const int64_t code = dspine_codebook_meta->ne[0];
    +        const int64_t rank = dspine_gate_meta->ne[1];
    +        const int64_t top_k = hparams.dflash_selector_top_k;
    +        if (top_k < 2 || n_embd < top_k * (top_k + 1) || selector_meta || hparams.dflash_block_size < 2) {
    +            throw std::runtime_error("invalid DSpine metadata");
    +        }
    +
    +        dspine_codebook  = create_tensor(tn(LLM_TENSOR_DSPINE_CODEBOOK,  "weight"), { code, n_vocab }, 0);
    +        dspine_gate      = create_tensor(tn(LLM_TENSOR_DSPINE_GATE,      "weight"), { code, rank }, 0);
    +        dspine_gate_b    = create_tensor(tn(LLM_TENSOR_DSPINE_GATE,      "bias"),   { rank }, 0);
    +        dspine_pred_gate = create_tensor(tn(LLM_TENSOR_DSPINE_PRED_GATE, "weight"), { code, rank }, 0);
    +        dspine_prev      = create_tensor(tn(LLM_TENSOR_DSPINE_PREV,      "weight"), { code, rank }, 0);
    +        for (int i = 0; i < n_layer; ++i) {
    +            layers[i].dspine_read  = create_tensor(tn(LLM_TENSOR_DSPINE_READ,  "weight", i), { n_embd, code }, 0);
    +            layers[i].dspine_write = create_tensor(tn(LLM_TENSOR_DSPINE_WRITE, "weight", i), { rank, n_embd }, 0);
    +        }
    +
    +        LLAMA_LOG_INFO("%s: DSpine code bridge (code = %lld, rank = %lld, top-k = %lld)\n", __func__,
    +                (long long) code, (long long) rank, (long long) top_k);
    +    }
     }
     
     template <>
    @@ -648,6 +673,152 @@
         ggml_build_forward_expand(g.gf, packed);
     }
     
    +// DSpine pre-write state of the last layer, read again by the lattice
    +struct dspine_stash {
    +    ggml_tensor * raw = nullptr; // [n_embd, n_tokens]
    +    ggml_tensor * rms = nullptr; // [1, n_tokens]
    +    ggml_tensor * q   = nullptr; // [rank, n_tokens] gate projection of each row's own code, no bias
    +};
    +
    +// anchor (token 0) of every block
    +static ggml_tensor * dspine_anchor_ids(llm_graph_context & g, ggml_tensor * tokens, int64_t block, int64_t n_blocks) {
    +    return ggml_cont_1d(g.ctx0, ggml_view_2d(g.ctx0, tokens, 1, n_blocks, block * tokens->nb[0], 0), n_blocks);
    +}
    +
    +// DSpine code bridge write after layer il: every row reads a unit code from its hidden state (the anchor row
    +// uses its token's codebook row), then row t gets a gated message from the code of row t-1
    +static ggml_tensor * build_dspine_write(llm_graph_context & g, const llama_model & model,
    +        ggml_tensor * cur, ggml_tensor * tokens, int il, dspine_stash * stash) {
    +    ggml_context * ctx0 = g.ctx0;
    +
    +    const auto & layer = model.layers[il];
    +
    +    const int64_t n_embd   = cur->ne[0];
    +    const int64_t n_tokens = cur->ne[1];
    +    const int64_t n_blocks = g.ubatch.n_seqs_unq;
    +    const int64_t code     = model.dspine_codebook->ne[0];
    +    const int64_t rank     = model.dspine_gate->ne[1];
    +    const float   eps      = g.hparams.f_norm_rms_eps;
    +
    +    GGML_ASSERT(n_blocks > 0 && n_tokens % n_blocks == 0);
    +    const int64_t block = n_tokens / n_blocks;
    +    if (block < 2) {
    +        return cur;
    +    }
    +
    +    // codes are L2-normalized, so the read is scale-invariant and only the rms is kept for the write
    +    ggml_tensor * rms = ggml_sqrt(ctx0, ggml_scale(ctx0, ggml_sum_rows(ctx0, ggml_sqr(ctx0, cur)), 1.0f/n_embd));
    +
    +    ggml_tensor * codes = g.build_lora_mm(layer.dspine_read, ggml_rms_norm(ctx0, cur, eps));
    +    codes = ggml_scale(ctx0, ggml_l2_norm(ctx0, codes, eps), sqrtf((float) code));
    +    g.cb(codes, "dspine_codes", il);
    +
    +    ggml_tensor * anchor_codes = ggml_get_rows(ctx0, model.dspine_codebook, dspine_anchor_ids(g, tokens, block, n_blocks));
    +    anchor_codes = ggml_scale(ctx0, ggml_reshape_3d(ctx0, anchor_codes, code, 1, n_blocks), sqrtf((float) code));
    +
    +    codes = ggml_reshape_3d(ctx0, codes, code, block, n_blocks);
    +    codes = ggml_concat(ctx0, anchor_codes,
    +            ggml_cont(ctx0, ggml_view_3d(ctx0, codes, code, block - 1, n_blocks, codes->nb[1], codes->nb[2], codes->nb[1])), 1);
    +    codes = ggml_reshape_2d(ctx0, codes, code, n_tokens);
    +
    +    ggml_tensor * q = ggml_reshape_3d(ctx0, g.build_lora_mm(model.dspine_gate,      codes), rank, block, n_blocks);
    +    ggml_tensor * s = ggml_reshape_3d(ctx0, g.build_lora_mm(model.dspine_pred_gate, codes), rank, block, n_blocks);
    +    ggml_tensor * v = ggml_reshape_3d(ctx0, g.build_lora_mm(model.dspine_prev,      codes), rank, block, n_blocks);
    +
    +    const auto rows = [&](ggml_tensor * t, int64_t beg) {
    +        return ggml_view_3d(ctx0, t, rank, block - 1, n_blocks, t->nb[1], t->nb[2], beg * t->nb[1]);
    +    };
    +
    +    // message(t) = sigmoid(Wg c_t + Wp c_(t-1) + b) * (Wv c_(t-1)), nothing for the anchor row
    +    ggml_tensor * gate = ggml_sigmoid(ctx0, ggml_add(ctx0, ggml_add(ctx0, rows(q, 1), rows(s, 0)), model.dspine_gate_b));
    +    ggml_tensor * msg  = ggml_mul(ctx0, gate, rows(v, 0));
    +
    +    ggml_tensor * delta = g.build_lora_mm(layer.dspine_write, ggml_reshape_2d(ctx0, msg, rank, (block - 1) * n_blocks));
    +    delta = ggml_pad_ext(ctx0, ggml_reshape_3d(ctx0, delta, n_embd, block - 1, n_blocks), 0, 0, 1, 0, 0, 0, 0, 0);
    +    delta = ggml_mul(ctx0, ggml_reshape_2d(ctx0, delta, n_embd, n_tokens), rms);
    +
    +    if (stash) {
    +        stash->raw = cur;
    +        stash->rms = rms;
    +        stash->q   = ggml_reshape_2d(ctx0, q, rank, n_tokens);
    +    }
    +
    +    return ggml_add(ctx0, cur, delta);
    +}
    +
    +// DSpine serial refinement: redo the last bridge write once per exact predecessor candidate and score the top-k
    +// candidates of every row, packed like the DFlash2 lattice: [cand (k), scores (k x k, predecessor-major)]
    +static void build_dspine_lattice(llm_graph_context & g, const llama_model & model, ggml_tensor * tokens,
    +        ggml_tensor * output, const dspine_stash & stash) {
    +    ggml_context * ctx0 = g.ctx0;
    +    auto         & res  = g.res;
    +
    +    const int64_t n_embd   = g.n_embd;
    +    const int64_t n_tokens = g.n_tokens;
    +    const int64_t n_blocks = g.ubatch.n_seqs_unq;
    +    const int64_t top_k    = g.hparams.dflash_selector_top_k;
    +    const int64_t code     = model.dspine_codebook->ne[0];
    +    const int64_t rank     = model.dspine_gate->ne[1];
    +
    +    GGML_ASSERT(n_blocks > 0 && n_tokens % n_blocks == 0);
    +    const int64_t block = n_tokens / n_blocks;
    +    const int64_t n_pos = block - 1;
    +    if (block < 2 || block > (int64_t) g.hparams.dflash_block_size || stash.raw == nullptr) {
    +        return;
    +    }
    +
    +    // rows 1..block-1 of every block, with a broadcast candidate dim: [ne0, 1, n_pos, n_blocks]
    +    const auto pos_rows = [&](ggml_tensor * t) {
    +        ggml_tensor * t3 = ggml_reshape_3d(ctx0, t, t->ne[0], block, n_blocks);
    +        t3 = ggml_cont(ctx0, ggml_view_3d(ctx0, t3, t->ne[0], n_pos, n_blocks, t3->nb[1], t3->nb[2], t3->nb[1]));
    +        return ggml_reshape_4d(ctx0, t3, t->ne[0], 1, n_pos, n_blocks);
    +    };
    +
    +    ggml_tensor * cand = ggml_reshape_3d(ctx0, ggml_top_k(ctx0, res->t_logits, top_k), top_k, block, n_blocks);
    +    ggml_tensor * cand_run = ggml_cont(ctx0, ggml_view_3d(ctx0, cand, top_k, n_pos, n_blocks, cand->nb[1], cand->nb[2], cand->nb[1]));
    +
    +    // exact predecessor codes: the anchor for row 1, the candidates of row t-1 for row t
    +    ggml_tensor * pred = ggml_get_rows(ctx0, model.dspine_codebook, dspine_anchor_ids(g, tokens, block, n_blocks));
    +    pred = ggml_repeat_4d(ctx0, ggml_reshape_4d(ctx0, pred, code, 1, 1, n_blocks), code, top_k, 1, n_blocks);
    +    if (n_pos > 1) {
    +        ggml_tensor * prev_ids = ggml_cont(ctx0, ggml_view_3d(ctx0, cand_run, top_k, n_pos - 1, n_blocks, cand_run->nb[1], cand_run->nb[2], 0));
    +        ggml_tensor * prev = ggml_get_rows(ctx0, model.dspine_codebook, ggml_reshape_1d(ctx0, prev_ids, top_k * (n_pos - 1) * n_blocks));
    +        pred = ggml_concat(ctx0, pred, ggml_reshape_4d(ctx0, prev, code, top_k, n_pos - 1, n_blocks), 2);
    +    }
    +    pred = ggml_scale(ctx0, ggml_reshape_2d(ctx0, pred, code, top_k * n_pos * n_blocks), sqrtf((float) code));
    +
    +    ggml_tensor * gp = ggml_reshape_4d(ctx0, g.build_lora_mm(model.dspine_pred_gate, pred), rank, top_k, n_pos, n_blocks);
    +    ggml_tensor * pv = ggml_reshape_4d(ctx0, g.build_lora_mm(model.dspine_prev,      pred), rank, top_k, n_pos, n_blocks);
    +
    +    ggml_tensor * gate = ggml_sigmoid(ctx0, ggml_add(ctx0, ggml_add(ctx0, gp, pos_rows(stash.q)), model.dspine_gate_b));
    +    ggml_tensor * msg  = ggml_mul(ctx0, gate, pv);
    +
    +    const auto & last = model.layers[g.n_layer - 1];
    +    ggml_tensor * delta = g.build_lora_mm(last.dspine_write, ggml_reshape_2d(ctx0, msg, rank, top_k * n_pos * n_blocks));
    +    delta = ggml_reshape_4d(ctx0, delta, n_embd, top_k, n_pos, n_blocks);
    +
    +    ggml_tensor * refined = ggml_add(ctx0, ggml_mul(ctx0, delta, pos_rows(stash.rms)), pos_rows(stash.raw));
    +    refined = g.build_norm(refined, model.output_norm, NULL, LLM_NORM_RMS, -1);
    +    g.cb(refined, "dspine_refined", -1);
    +
    +    // table[k][j]: logit of candidate k after the write with predecessor candidate j
    +    ggml_tensor * head = ggml_get_rows(ctx0, output, ggml_reshape_1d(ctx0, cand_run, top_k * n_pos * n_blocks));
    +    head = ggml_reshape_4d(ctx0, head, n_embd, top_k, n_pos, n_blocks);
    +    ggml_tensor * table = ggml_mul_mat(ctx0, head, refined);
    +
    +    ggml_tensor * row = ggml_concat(ctx0,
    +            ggml_cast(ctx0, cand_run, GGML_TYPE_F32),
    +            ggml_reshape_3d(ctx0, table, top_k * top_k, n_pos, n_blocks), 0);
    +    row = ggml_pad(ctx0, row, n_embd - top_k - top_k * top_k, 0, 0, 0);
    +
    +    ggml_tensor * packed = ggml_fill(ctx0, ggml_new_tensor_3d(ctx0, GGML_TYPE_F32, n_embd, 1, n_blocks), 0.0f);
    +    packed = ggml_reshape_2d(ctx0, ggml_concat(ctx0, packed, row, 1), n_embd, n_tokens);
    +    g.cb(packed, "dspine_lattice", -1);
    +
    +    res->t_h_nextn = packed;
    +    ggml_build_forward_expand(g.gf, packed);
    +}
    +
     static void build_lilicorr_scores(llm_graph_context & g, const llama_model & model,
             ggml_tensor * tok_embd, ggml_tensor * anchors) {
         ggml_context * ctx0 = g.ctx0;
    @@ -960,6 +1131,8 @@
         }
         cb(inpL, "inp_noise_embd", -1);
     
    +    dspine_stash dspine;
    +
         for (int il = 0; il < n_layer; ++il) {
             const auto & layer = model.layers[il];
     
    @@ -1049,6 +1222,10 @@
             if (layer.out_scale) {
                 cur = ggml_mul(ctx0, cur, layer.out_scale);
             }
    +
    +        if (layer.dspine_write) {
    +            cur = build_dspine_write(*this, model, cur, inp_tokens, il, il == n_layer - 1 ? &dspine : nullptr);
    +        }
             cb(cur, "l_out", il);
     
             inpL = cur;
    @@ -1110,6 +1287,8 @@
     
         if (model.dflash_selector_hidden) {
             build_dflash2_selector(*this, model, inp_tokens);
    +    } else if (model.dspine_codebook) {
    +        build_dspine_lattice(*this, model, inp_tokens, output, dspine);
         } else if (model.lilicorr_pass_hidden_proj && ubatch.embd_state && n_tokens == (int64_t) hparams.dflash_block_size * ubatch.n_seqs_unq) {
             build_lilicorr_scores(*this, model, tok_embd, inp_anchor);
         }
  '';
in
llamaCuda.overrideAttrs (old: {
  pname = "llama-cpp-dspine";

  patches = (old.patches or [ ]) ++ [
    runtimePatch
    ./llama-offload-speedups.patch
  ];

  passthru = (old.passthru or { }) // {
    inherit llamaCuda baseRevision dspineRevision runtimePatch;
  };
})
