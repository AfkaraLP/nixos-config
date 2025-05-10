{ config, pkgs, lib, ... }:

{
  programs.nixcord = {
    enable = true;
    vesktop.enable = true;
    config = {
      themeLinks = [];
      frameless = true;
      transparent = true;
      plugins = {
        alwaysAnimate.enable = true;
	alwaysExpandRoles.enable = true;
	biggerStreamPreview.enable = true;
	callTimer.enable = true;
	clearURLs.enable = true;
	copyFileContents.enable = true;
	dearrow = {
	  enable = true;
	  hideButton = true;
	  replaceElements = "titles";
	}; # dearrow 
	dontRoundMyTimestamps.enable = true;
	emoteCloner.enable = true;
	fakeNitro.enable = true;
	favoriteEmojiFirst.enable = true;
	favoriteGifSearch.enable = true;
	fixImagesQuality.enable = true;
	fixSpotifyEmbeds.enable = true;
	fixYoutubeEmbeds.enable = true;
	forceOwnerCrown.enable = true;
	imageZoom.enable = true;
	messageLogger = {
	  enable = true;
	  collapseDeleted = true;
	  ignoreBots = true;
	  ignoreSelf = true;
	}; # messageLogger 
	noDevtoolsWarning.enable = true;
	noF1.enable = true;
	pinDMs.enable = true;
	spotifyCrack.enable = true;
	startupTimings.enable = true;
	textReplace = {
	  enable = true;
	  regexRules = [
	    {
              find = "/^https:\\/\\/x\\";
              replace = "https://fixvx";
              onlyIfIncludes = "";
            }
	    {
	      find = "/^https?:\\/\\/(?:www\\.)?reddit";
	      replace = "https://www.rxddit";
	      onlyIfIncludes = "";
	    }
	    {
	      find = "/^https?:\\/\\/(?:www\\.)?instagram";
	      replace = "https://www.ddinstagram";
	      onlyIfIncludes = "";
	    }
	    {
	      find = "https?:\\/\\/(www)?\\.tiktok";  
	      replace = "https://www.vxtiktok";
	      onlyIfIncludes = "";
	    }
	    {
	      find = "?is_from_webapp.*";
	      replace = "";
	      onlyIfIncludes = "";
	    }
	    {
	      find = "?utm_source.*";
	      replace = "";
	      onlyIfIncludes = "";
	    }
	  ]; # regexRules 
	}; # textReplace 
	typingTweaks.enable = true;
	voiceDownload.enable = true;
	voiceMessages.enable = true;
	volumeBooster.enable = true;
	youtubeAdblock.enable = true;
	webScreenShareFixes.enable = true;
      }; # plugins 
    }; # config 
  }; # programs.nixcord 
}
