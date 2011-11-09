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

s3eResult ApplifierCrossPromotionInitialize(const char* applifierID, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp)
{
	return ApplifierCrossPromotionInitialize_platform(applifierID, orientationHomeButtonDown, orientationHomeButtonRight, orientationHomeButtonLeft, orientationHomeButtonUp);
}

bool ApplifierCrossPromotionShowBanner(int positionX, int positionY)
{
	return ApplifierCrossPromotionShowBanner_platform(positionX, positionY);
}

bool ApplifierCrossPromotionMoveBanner(int x, int y)
{
	return ApplifierCrossPromotionMoveBanner_platform(x, y);
}

bool ApplifierCrossPromotionHideBanner() 
{
	return ApplifierCrossPromotionHideBanner_platform();
}

bool ApplifierCrossPromotionPrepareFeaturedGames()
{
	return ApplifierCrossPromotionPrepareFeaturedGames_platform();
}

bool ApplifierCrossPromotionPrepareInterstitial()
{
	return ApplifierCrossPromotionPrepareInterstitial_platform();
}

bool ApplifierCrossPromotionIsFeaturedGamesReady()
{
	return ApplifierCrossPromotionIsFeaturedGamesReady_platform();
}

bool ApplifierCrossPromotionIsInterstitialReady()
{
	return ApplifierCrossPromotionIsInterstitialReady_platform();
}

bool ApplifierCrossPromotionShowFeaturedGames()
{
	return ApplifierCrossPromotionShowFeaturedGames_platform();
}

bool ApplifierCrossPromotionShowInterstitial()
{
	return ApplifierCrossPromotionShowInterstitial_platform();
}

bool ApplifierCrossPromotionPauseRenderer()
{
	return ApplifierCrossPromotionPauseRenderer_platform();
}
