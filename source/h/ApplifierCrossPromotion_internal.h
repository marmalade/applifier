/*
Internal header for the ApplifierCrossPromotion extension.

This file should be used for any common function definitions etc that need to
be shared between the platform-dependent and platform-indepdendent parts of
this extension.
*/

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#ifndef APPLIFIERCROSSPROMOTION_H_INTERNAL
#define APPLIFIERCROSSPROMOTION_H_INTERNAL

#include "s3eTypes.h"
#include "ApplifierCrossPromotion.h"
#include "ApplifierCrossPromotion_autodefs.h"


/**
 * Initialise the extension.  This is called once then the extension is first
 * accessed by s3eregister.  If this function returns S3E_RESULT_ERROR the
 * extension will be reported as not-existing on the device.
 */
s3eResult ApplifierCrossPromotionInit();

/**
 * Platform-specific initialisation, implemented on each platform
 */
s3eResult ApplifierCrossPromotionInit_platform();

/**
 * Terminate the extension.  This is called once on shutdown, but only if the
 * extension was loader and Init() was successful.
 */
void ApplifierCrossPromotionTerminate();

/**
 * Platform-specific termination, implemented on each platform
 */
void ApplifierCrossPromotionTerminate_platform();
s3eResult ApplifierCrossPromotionInitialize_platform(const char* applifierID, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp);

bool ApplifierCrossPromotionShowBanner_platform(int positionX, int positionY);

bool ApplifierCrossPromotionMoveBanner_platform(int x, int y);

bool ApplifierCrossPromotionHideBanner_platform();

bool ApplifierCrossPromotionPrepareFeaturedGames_platform();

bool ApplifierCrossPromotionPrepareInterstitial_platform();

bool ApplifierCrossPromotionIsFeaturedGamesReady_platform();

bool ApplifierCrossPromotionIsInterstitialReady_platform();

bool ApplifierCrossPromotionShowFeaturedGames_platform();

bool ApplifierCrossPromotionShowInterstitial_platform();

bool ApplifierCrossPromotionPauseRenderer_platform();

#endif /* APPLIFIERCROSSPROMOTION_H_INTERNAL */