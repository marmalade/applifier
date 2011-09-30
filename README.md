Register to Applifier cross-promotion network here: http://www.applifier.com/mobile/ 

# Applifier integration instructions for Marmalade #

1. Get applifier extension from github. You should go to terminal, and change directory to Marmalade/x.x/extensions folder, and clone the applifier repository to a directory. Example: 

        cd /Developer/Marmalade/5.1/extensions
        git clone git@github.com:marmalade/applifier.git

    Unzip the provided package to the extensions folder, example:
    
        /Developer/Marmalade/5.1/extensions 

2. Add applifier to your project as a subproject by modifying your project mkb file

    Example:

        #!/usr/bin/env mkb
        files
        {
          ... 
        }

        subprojects
        {
        	applifier
        }

        assets
        {
        	...
        }
        deployments 
        {
        	...
        }



3. Modify the deployments section of your project mkb file to include url-scheme settings for facebook connect single sign on and additional Activity info for Android.

    Example: 

        subprojects 
        {
        	ApplifierCrossPromotion
        }
        deployments 
        {
          name='ApplifierTest'
          ["My config"]
          "android,iphone"
          iphone-bundle-url-name="com.applifier.FacebookConnect"
        	iphone-bundle-url-schemes="fb103673636361992xxxxxxxxxxxxxxxxxxxx"
        	android-extra-application-manifest="ApplifierFullscreenActivity.manifest"
        }

    Replace xxxxxxxxxxxxxxxxxxxx with your applifier id. Do not modify the preceding part of the string. 

    You can change the name (‘ApplifierTest’) as well as “My config”. When you’re deploying, remember to choose this configuration.

    For Android, the file ApplifierFullscreenActivity.manifest (can be found in extensions/applifier directory) must be copied to your project root directory. This registers Applifier fullscreen activity for android os. If it’s missing, fullscreen view wont work, as the Android OS cant find the Activity.

4. You must now click the project mkb file to launch IDE. This action will include the subproject to your project.

5. Import the extension header file

    Example:

        #include "ApplifierCrossPromotion.h"

6. Init the Applifier library with your applifier id as early on in your application’s lifecycle as possible, preferably in your initial loading sequence: 

    Example:

        if (ApplifierCrossPromotionAvailable()) {
          init("xxxxxxxxxxxxxxxxxxxx", true, true, true, true);
        }

    Replace the xxxxxxxxxxxxxxxxxxxx with your Applifier ID. The four boolean values following it in the initialization are used to flag which screen rotations to support. Applifier views will rotate automatically. The booleans for rotations are in the following order: Home button down, home button right, home button left, home button up. Note: On Android, rotations have currently no effect, and the view will rotate automatically.

7. Now you can call the desired ad functions. 

    To show a banner on screen, call the following: 

        showBanner(5,10);

    (Calling showBanner(x,y) will also commence the banner loading, so it may take a short while before the banner appears on screen. The coordinates are from the upper left corner of the banner. Refer to the ApplifierMobile-iOS_Integration_Guide.pdf document for more on banner dimensions and positioning.)

    To hide the banner, call

        hideBanner();

    To show featured games (aka. your “more games” implementation) you have to first prepare the featured games view (preparing the view preloads images and other content required by the “featured games” page). First call:

        prepareFeaturedGames();

    And later when you need to show the screen, call 

        bool didLaunchFeaturedGamesView = showFeaturedGames();

    showFeaturedGames() does nothing until all the content for it has been loaded, so it is adviced to call prepareFeaturedGames() well in advance to calling showFeaturedGames(). If you are using the “more games” button in your main menu, for example, you should call prepareFeaturedGames() in the early stages of your app’s loading, so that showFeaturedGames() can be used upon entering the main menu. 

    Showing interstitial ad works the same way:

        prepareInterstitial();

    And later when you need to show the screen, call 

        bool didLaunchInterstitialView = showInterstitial();

    When Applifier view is in fullscreen mode, its recommended to pause your game renderer & other cpu consuming logic to improve end user experience in the Applifier view. Our library provides a helper for this:

        while (rendering) {
          if (pauseRenderer() == false)  {
            //Render code
          }

          //Flush IwGx
          IwGxFlush();
          //Display the rendered frame
          IwGxSwapBuffers();
        }


	
    Note: We noticed that when running on android, you need to call  IwGxFlush();  and IwGxSwapBuffers(); functions on every frame while paused. If you don’t call these, the application may crash and exit after couple minutes when in paused mode. (in fullscreen mode)

That’s it. Contact support@applifier.com if having problems. We are happy to help.
