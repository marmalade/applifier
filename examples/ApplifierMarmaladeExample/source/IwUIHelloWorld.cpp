/*
 * This file is part of the Marmalade SDK Code Samples.
 *
 * Copyright (C) 2001-2011 Ideaworks3D Ltd.
 * All Rights Reserved.
 *
 * This source code is intended only as a supplement to Ideaworks Labs
 * Development Tools and/or on-line documentation.
 *
 * THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
 * KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
 * PARTICULAR PURPOSE.
 */

//-----------------------------------------------------------------------------
// ExampleIwUIHelloWorld
//-----------------------------------------------------------------------------

/**
 * @page ExampleIwUIHelloWorld IwUI Hello World Example
 * The following example demonstrates simple load and display of a dialogue.
 *
 * The main classes used to achieve this are:
 *
 * <ul>
 * <li> CIwUIView
 *
 * <li> CIwUIController
 *
 * <li> CIwUIElement
 *
 * <li> CIwUIStyleSheetManager
 * </ul>
 *
 * The main functions used to achieve this are:
 *
 * <ul>
 * <li> IwUIInit()
 *
 * <li> IwUITerminate();
 *
 * </ul>
 *
 * This example demonstrates the loading and instantiation of an element defined in data.
 *
 * In IwUI, elements are typically stored as a standard resource in IwResManager. It is
 * good practise to clone these resources rather than using them directly. Elements can also
 * be dynamically built from code. See the IwUIHelloWorldDynamic for an example of this usage.
 *
 * Once the element has been cloned it is added to the UI view singleton. The UI view
 * contains the root element and is responsible for maintaining the elements.
 *
 * The CIwUIController is a singleton that converts input into events. Events from the system
 * are constantly gathered and are dispatched when CIwUIController::Update is called.
 *
 * For the button to function CIwUIView::Update and CIwUIController::Update must be called.
 *
 * This example registers a single global handler (CHelloWorldHandler) to exit on button presses.
 *
 * Finally CIwUIView::Render is called to render the UI.
 *
 * The following graphic illustrates the example output.
 *
 * @image html IwUIHelloWorldImage.png
 *
 * @include IwUIHelloWorld.cpp
 *
 */
// @}


#include "IwGx.h"
#include "IwUI.h"
#include "ApplifierCrossPromotion.h"

class ButtonHandler : public CIwUIController
{
public:
    ButtonHandler()
    {
	    IwTrace(ButtonHandler, ("ButtonHandler constructor"));

        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickBanner, CIwUIElement*)
        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickHideBanner, CIwUIElement*)
        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickPrepareFeaturedGames, CIwUIElement*)
        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickPrepareInterstitial, CIwUIElement*)
        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickFeaturedGames, CIwUIElement*)
        IW_UI_CREATE_VIEW_SLOT1(this, "ButtonHandler", ButtonHandler, OnClickInterstitial, CIwUIElement*)
    }
	
	//show banner
    void OnClickBanner(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionShowBanner(25,30);
    }

	//show banner
    void OnClickHideBanner(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionHideBanner();
    }
	
	
    //show featured games
    void OnClickFeaturedGames(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionShowFeaturedGames();
    }
	
	//show interstitial
    void OnClickInterstitial(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionShowInterstitial();
    }
    //prepare featured games
    void OnClickPrepareFeaturedGames(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionPrepareFeaturedGames();
    }
	
	//prepare interstitial
    void OnClickPrepareInterstitial(CIwUIElement*)
    {
		if (ApplifierCrossPromotionAvailable())
			ApplifierCrossPromotionPrepareInterstitial();
    }
	
};

class CPointerWatcher : public IIwUIEventHandler
{
public:
    virtual    bool FilterEvent(CIwEvent* pEvent)
    {
        if (pEvent->GetID() == IWUI_EVENT_CLICK)
        {
            CIwUIEventClick* pClick = IwSafeCast<CIwUIEventClick*>(pEvent);
			
            IwTrace(UI, ("Pointer click %s at %d, %d",
						 pClick->GetPressed() ? "down" : "up",
						 pClick->GetPos().x, pClick->GetPos().y));           

			//if (ApplifierCrossPromotionAvailable())
			//	moveBanner(pClick->GetPos().x, pClick->GetPos().y);

		}
        else if (pEvent->GetID() == IWUI_EVENT_POINTER_MOVE)
        {
            CIwUIEventPointerMove* pMove = IwSafeCast<CIwUIEventPointerMove*>(pEvent);
			
            IwTrace(UI, ("Pointer moved to %d, %d",
						 pMove->GetPos().x, pMove->GetPos().y));
			if (ApplifierCrossPromotionAvailable())
				ApplifierCrossPromotionMoveBanner(pMove->GetPos().x, pMove->GetPos().y);
        }
		
        return false;
    }
	
    virtual bool HandleEvent(CIwEvent* pEvent)
    {
        return false;
    }
};



ButtonHandler* buttonHandler = NULL;

void ExampleInit()
{
	//Initialise the IwUI module
    IwUIInit();
	
    //Instantiate the view and controller singletons.
    //IwUI will not instantiate these itself, since they can be subclassed to add functionality.
    //new CIwUIController;
    new CIwUIView;

    // Instantiate class to deal with events
    buttonHandler = new ButtonHandler; //extends CIwUIView
	
    //Provide global event handler
    //IwGetUIController()->AddEventHandler(&g_HelloWorldHandler);

    //Load the hello world UI
    IwGetResManager()->LoadGroup("IwUIHelloWorld.group");

    //Set the default style sheet
    CIwResource* pResource = IwGetResManager()->GetResNamed("iwui", IW_UI_RESTYPE_STYLESHEET);
    IwGetUIStyleManager()->SetStylesheet(IwSafeCast<CIwUIStylesheet*>(pResource));

    //Find the dialog template
    CIwUIElement* pDialogTemplate = (CIwUIElement*)IwGetResManager()->GetResNamed("Vertical", "CIwUIElement");

    //And instantiate it
    CIwUIElement* pDialog = pDialogTemplate->Clone();
    IwGetUIView()->AddElement(pDialog);
    IwGetUIView()->AddElementToLayout(pDialog);
	
	IwGetUIController()->AddEventHandler(new CPointerWatcher);
	
	if (ApplifierCrossPromotionAvailable()) {
		ApplifierCrossPromotionInitialize("asdf", true, true, true, true);
	}
	
}
//-----------------------------------------------------------------------------
void ExampleShutDown()
{
    delete IwGetUIController();
    delete IwGetUIView();

    //Terminate the IwUI module
    IwUITerminate();
}
//----------------------------------------------------------------------------


bool ExampleUpdate()
{
    //Update the controller (this will generate control events etc.)
    IwGetUIController()->Update();

    //Update the view (this will do animations etc.) The SDK's example framework has a fixed
    //framerate of 20fps, so we pass that duration to the update function.
    IwGetUIView()->Update(1000/20);

    return true;
}
//-----------------------------------------------------------------------------

bool interstitialShowing = false;

void ExampleRender()
{

	if (ApplifierCrossPromotionAvailable() == false || ApplifierCrossPromotionPauseRenderer() == false)  {
		IwGetUIView()->Render();
	}
	
    //Flush IwGx
    IwGxFlush();
    //Display the rendered frame
    IwGxSwapBuffers();
}
