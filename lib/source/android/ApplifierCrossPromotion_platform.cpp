/*
 * android-specific implementation of the ApplifierCrossPromotion extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "ApplifierCrossPromotion_internal.h"

#include "s3eEdk.h"
#include "s3eEdk_android.h"
#include <jni.h>
#include "IwDebug.h"

static jobject g_Obj;
static jmethodID g_init;
static jmethodID g_showBanner;
static jmethodID g_moveBanner;
static jmethodID g_hideBanner;
static jmethodID g_prepareFeaturedGames;
static jmethodID g_prepareInterstitial;
static jmethodID g_prepareCustomInterstitial;
static jmethodID g_prepareAnimated;
static jmethodID g_isFeaturedGamesReady;
static jmethodID g_isInterstitialReady;
static jmethodID g_isCustomInterstitialReady;
static jmethodID g_isAnimatedReady;
static jmethodID g_showFeaturedGames;
static jmethodID g_showInterstitial;
static jmethodID g_showCustomInterstitial;
static jmethodID g_showAnimated;
static jmethodID g_pauseRenderer;

s3eResult ApplifierCrossPromotionInit_platform()
{
    //Get the environment from the pointer
    JNIEnv* env = s3eEdkJNIGetEnv();
    jobject obj = NULL;
    jmethodID cons = NULL;

    //Get the extension class
    jclass cls = s3eEdkAndroidFindClass("ApplifierCrossPromotion");
    if (!cls)
        goto fail;

    //Get its constructor
    cons = env->GetMethodID(cls, "<init>", "()V");
    if (!cons)
        goto fail;

    //Construct the java class
    obj = env->NewObject(cls, cons);
    if (!obj)
        goto fail;

    //Get all the extension methods
    g_init = env->GetMethodID(cls, "init", "(Ljava/lang/String;ZZZZ)I");
    if (!g_init)
        goto fail;

    g_showBanner = env->GetMethodID(cls, "showBanner", "(II)Z");
    if (!g_showBanner)
        goto fail;

    g_moveBanner = env->GetMethodID(cls, "moveBanner", "(II)Z");
    if (!g_moveBanner)
        goto fail;

    g_hideBanner = env->GetMethodID(cls, "hideBanner", "()Z");
    if (!g_hideBanner)
        goto fail;

    g_prepareFeaturedGames = env->GetMethodID(cls, "prepareFeaturedGames", "()Z");
    if (!g_prepareFeaturedGames)
        goto fail;

    g_prepareInterstitial = env->GetMethodID(cls, "prepareInterstitial", "()Z");
    if (!g_prepareInterstitial)
        goto fail;

    g_prepareCustomInterstitial = env->GetMethodID(cls, "prepareCustomInterstitial", "()Z");
    if (!g_prepareCustomInterstitial)
        goto fail;

    g_prepareAnimated = env->GetMethodID(cls, "prepareAnimated", "(I)Z");
    if (!g_prepareAnimated)
        goto fail;

    g_isFeaturedGamesReady = env->GetMethodID(cls, "isFeaturedGamesReady", "()Z");
    if (!g_isFeaturedGamesReady)
        goto fail;

    g_isInterstitialReady = env->GetMethodID(cls, "isInterstitialReady", "()Z");
    if (!g_isInterstitialReady)
        goto fail;

    g_isCustomInterstitialReady = env->GetMethodID(cls, "isCustomInterstitialReady", "()Z");
    if (!g_isCustomInterstitialReady)
        goto fail;

    g_isAnimatedReady = env->GetMethodID(cls, "isAnimatedReady", "()Z");
    if (!g_isAnimatedReady)
        goto fail;

    g_showFeaturedGames = env->GetMethodID(cls, "showFeaturedGames", "()Z");
    if (!g_showFeaturedGames)
        goto fail;

    g_showInterstitial = env->GetMethodID(cls, "showInterstitial", "()Z");
    if (!g_showInterstitial)
        goto fail;

    g_showCustomInterstitial = env->GetMethodID(cls, "showCustomInterstitial", "()Z");
    if (!g_showCustomInterstitial)
        goto fail;

    g_showAnimated = env->GetMethodID(cls, "showAnimated", "(I)Z");
    if (!g_showAnimated)
        goto fail;

    g_pauseRenderer = env->GetMethodID(cls, "pauseRenderer", "()Z");
    if (!g_pauseRenderer)
        goto fail;


    IwTrace(ApplifierMarmalade, ("ApplifierCrossPromotion init success"));
    g_Obj = env->NewGlobalRef(obj);
    env->DeleteLocalRef(obj);
    env->DeleteLocalRef(cls);
    
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
    
fail:
    jthrowable exc = env->ExceptionOccurred();
    IwTrace(ApplifierMarmalade, ("Coder has appointment with failure"));
    if (exc)
    {
        env->ExceptionDescribe();
        env->ExceptionClear();
        IwTrace(ApplifierMarmalade, ("One or more java methods could not be found"));
    }
    return S3E_RESULT_ERROR;

}

void ApplifierCrossPromotionTerminate_platform()
{
    // Add any platform-specific termination code here
}

s3eResult ApplifierCrossPromotionInitialize_platform(const char* applifierID, bool orientationHomeButtonDown, bool orientationHomeButtonRight, bool orientationHomeButtonLeft, bool orientationHomeButtonUp)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring applifierID_jstr = env->NewStringUTF(applifierID);
    return (s3eResult)env->CallIntMethod(g_Obj, g_init, applifierID_jstr, orientationHomeButtonDown, orientationHomeButtonRight, orientationHomeButtonLeft, orientationHomeButtonUp);
}

char* ApplifierCrossPromotionGetPlatform_platform()
{   
    char* platform = "Android";   
    return platform;
}

bool ApplifierCrossPromotionShowBanner_platform(int positionX, int positionY)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_showBanner, positionX, positionY);
}

bool ApplifierCrossPromotionMoveBanner_platform(int x, int y)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_moveBanner, x, y);
}

bool ApplifierCrossPromotionHideBanner_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_hideBanner);
}

bool ApplifierCrossPromotionPrepareFeaturedGames_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_prepareFeaturedGames);
}

bool ApplifierCrossPromotionPrepareInterstitial_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_prepareInterstitial);
}

bool ApplifierCrossPromotionPrepareCustomInterstitial_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_prepareCustomInterstitial);
}

bool ApplifierCrossPromotionPrepareAnimated_platform(int corner)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_prepareAnimated, corner);
}

bool ApplifierCrossPromotionIsFeaturedGamesReady_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_isFeaturedGamesReady);
}

bool ApplifierCrossPromotionIsInterstitialReady_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_isInterstitialReady);
}

bool ApplifierCrossPromotionIsCustomInterstitialReady_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_isCustomInterstitialReady);
}

bool ApplifierCrossPromotionIsAnimatedReady_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_isAnimatedReady);
}

bool ApplifierCrossPromotionShowFeaturedGames_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_showFeaturedGames);
}

bool ApplifierCrossPromotionShowInterstitial_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_showInterstitial);
}

bool ApplifierCrossPromotionShowCustomInterstitial_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_showCustomInterstitial);
}

bool ApplifierCrossPromotionShowAnimated_platform(int corner)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_showAnimated, corner);
}

bool ApplifierCrossPromotionPauseRenderer_platform()
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (bool)env->CallBooleanMethod(g_Obj, g_pauseRenderer);
}
