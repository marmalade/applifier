/*
Generic implementation of the ApplifierCrossPromotion extension.
This file should perform any platform-indepedentent functionality
(e.g. error checking) before calling platform-dependent implementations.
*/

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#include "ApplifierCrossPromotion_internal.h"
s3eResult ApplifierCrossPromotionInit()
{
    //Add any generic initialisation code here
    return ApplifierCrossPromotionInit_platform();
}

void ApplifierCrossPromotionTerminate()
{
    //Add any generic termination code here
    ApplifierCrossPromotionTerminate_platform();
}

s3eResult init(const char* applifierID, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp)
{
	return init_platform(applifierID, orientationHomeButtonDown, orientationHomeButtonRight, orientationHomeButtonLeft, orientationHomeButtonUp);
}

bool showBanner(int positionX, int positionY)
{
	return showBanner_platform(positionX, positionY);
}

bool hideBanner() 
{
	return hideBanner_platform();
}

bool prepareFeaturedGames()
{
	return prepareFeaturedGames_platform();
}

bool prepareInterstitial()
{
	return prepareInterstitial_platform();
}

bool isFeaturedGamesReady()
{
	return isFeaturedGamesReady_platform();
}

bool isInterstitialReady()
{
	return isInterstitialReady_platform();
}

bool showFeaturedGames()
{
	return showFeaturedGames_platform();
}

bool showInterstitial()
{
	return showInterstitial_platform();
}

bool pauseRenderer()
{
	return pauseRenderer_platform();
}
