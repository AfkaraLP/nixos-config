{config, pkgs, lib, ...}:
{
  programs.wofi = {
    enable = true;
    settings = {
      location = "center";
      matching = "fuzzy";
      insensitive = true;
      allow_images = true;
      layer = "overlay";
      normal_window = true;
      hide_search = true;
      dynamic_lines = true;
    };
    style = ''
        /* Base reset */
        * {
            background-color: transparent;
            color: #FFFFFF;
            margin: 0;
            padding: 0;
            font-weight: normal;
        }

        /* Main window container */
        #window {
            background-color: rgba(0, 0, 0, 0.5);
            border: 2px solid rgba(58, 58, 58, 0.66);
            border-radius: 10px;
            margin: 5px;
            padding: 8px;
            overflow: hidden;             /* <-- clip children to rounded corners */
            max-height: 80vh;             /* <-- prevent growing past viewport */
        }

        /* Hide the built-in search input */
        #input {
            display: none;
        }

        /* Outer box wrapping everything */
        #outer-box {
            background-color: transparent;
            border: none;
            border-radius: 10px;
            margin: 4px;
            padding: 4px;
        }

        /* Scrolled entry list */
        #scroll {
            background-color: transparent;
            border: none;
            border-radius: 0 0 10px 10px; /* <-- round bottom corners */
            margin: 4px 0;
            padding: 4px 0 8px 0;          /* <-- extra bottom padding */
            overflow-y: auto;
        }

        /* Inner entry container */
        #inner-box {
            background-color: rgba(0, 0, 0, 0.5);
            border: 2px solid rgba(58, 58, 58, 0.66);
            border-radius: 10px;
            padding: 6px;
            margin: 4px 0;
        }

        /* Individual entry wrapper */
        #entry {
            background-color: transparent;
            border: none;
            border-radius: 8px;
            margin: 2px 0;
            padding: 6px 8px;
            transition: background-color 0.15s ease-in-out;
        }
        #entry:selected,
        #entry:hover {
            background-color: rgba(137, 180, 250, 0.3);
        }

        /* Entry image */
        #img {
            margin-right: 8px;
            border-radius: 6px;
            min-width: 24px;
            min-height: 24px;
        }
        #img:selected {
            background-color: rgba(137, 180, 250, 0.8);
        }

        /* Entry text */
        #text {
            color: #FFFFFF;
            font-size: 0.95em;
            vertical-align: middle;
        }
        #text:selected {
            color: #1E1E2E;
        }

        /* Un/selected classes (legacy) */
        #unselected {
            opacity: 0.8;
        }
        #selected {
            opacity: 1.0;
        }

        /* Expander boxes for multi-action entries */
        #expander-box {
            background-color: rgba(0, 0, 0, 0.4);
            border-radius: 8px;
            padding: 4px;
            margin-top: 4px;
        }

    '';
  };
}
