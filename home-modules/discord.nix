{ ... }:

let
  # TextReplace regex rules, applied to outgoing messages.
  # `find` is a JS regex (global flag implied), `replace` supports $1 etc.
  linkFixes = [
    {
      name = "twitter";
      find = ''https?://(?:www\.|mobile\.)?(?:x|twitter)\.com/'';
      replace = "https://fixvx.com/";
    }
    {
      name = "instagram";
      find = ''https?://(?:www\.)?instagram\.com/'';
      replace = "https://kkinstagram.com/";
    }
    {
      name = "tiktok";
      find = ''https?://(www\.|vm\.|vt\.)?tiktok\.com/'';
      replace = "https://$1tnktok.com/";
    }
    {
      name = "reddit";
      find = ''https?://(?:www\.|old\.|new\.)?reddit\.com/'';
      replace = "https://rxddit.com/";
    }
    {
      name = "bluesky";
      find = ''https?://bsky\.app/'';
      replace = "https://fxbsky.app/";
    }
    {
      name = "pixiv";
      find = ''https?://(?:www\.)?pixiv\.net/'';
      replace = "https://phixiv.net/";
    }
  ];

  mkRule = r:
    {
      onlyIfIncludes = "";
      scope = "myMessages";
    } // r;
  # Vencord's settings UI expects a trailing empty rule row.
  emptyRule = mkRule {
    name = "";
    find = "";
    replace = "";
  };
in {
  programs.nixcord = {
    enable = true;
    discord.vencord.enable = true;

    config = {
      useQuickCss = true;
      frameless = false;

      plugins = {
        betterFolders.enable = true;
        betterRoleDot.enable = true;
        betterSessions.enable = true;
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        callTimer.enable = true;
        clearUrls.enable = true;
        copyFileContents.enable = true;
        crashHandler.enable = true;
        fakeNitro.enable = true;
        fixCodeblockGap.enable = true;
        fixImagesQuality.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        fullSearchContext.enable = true;
        imageZoom.enable = true;
        memberCount.enable = true;
        mentionAvatars.enable = true;
        messageClickActions.enable = true;
        messageLinkEmbeds.enable = true;
        messageLogger.enable = true;
        noF1.enable = true;
        noOnboardingDelay.enable = true;
        noUnblockToJump.enable = true;
        permissionsViewer.enable = true;
        pinDms.enable = true;
        platformIndicators.enable = true;
        previewMessage.enable = true;
        quickReply.enable = true;
        readAllNotificationsButton.enable = true;
        replyTimestamp.enable = true;
        reverseImageSearch.enable = true;
        shikiCodeblocks.enable = true;
        showHiddenChannels.enable = true;
        silentTyping.enable = true;
        translate.enable = true;
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        unsuppressEmbeds.enable = true;
        userVoiceShow.enable = true;
        validUser.enable = true;
        viewIcons.enable = true;
        voiceDownload.enable = true;
        voiceMessages.enable = true;
        volumeBooster.enable = true;
        webScreenShareFixes.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;

        textReplace = {
          enable = true;
          stringRules = [ emptyRule ];
          regexRules = map mkRule linkFixes ++ [ emptyRule ];
        }; # textReplace
      }; # plugins
    }; # config
  }; # programs.nixcord
}
