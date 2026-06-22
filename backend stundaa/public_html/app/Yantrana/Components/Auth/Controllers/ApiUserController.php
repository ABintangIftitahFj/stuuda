<?php
/**
 * WhatsJet
 *
 * This file is part of the WhatsJet software package developed and licensed by livelyworks.
 *
 * You must have a valid license to use this software.
 *
 * © 2024 - 2026 livelyworks. All rights reserved.
 * Redistribution or resale of this file, in whole or in part, is prohibited without prior written permission from the author.
 *
 * For support or inquiries, contact: contact@livelyworks.net
 *
 * @package     WhatsJet
 * @author      livelyworks <contact@livelyworks.net>
 * @copyright   Copyright (c) 2024 - 2026 livelyworks
 * @website     https://livelyworks.net
 */

/**
* UserController.php - Controller file
*
* This file is part of the User component.
*-----------------------------------------------------------------------------*/

namespace App\Yantrana\Components\Auth\Controllers;

use Illuminate\Http\Request;
use App\Yantrana\Base\BaseController;
use App\Yantrana\Support\CommonPostRequest;
use App\Yantrana\Components\Auth\AuthEngine;
use App\Yantrana\Components\User\UserEngine;
use App\Yantrana\Support\CommonClearPostRequest;
use App\Yantrana\Components\Auth\Requests\LoginRequest;
use App\Yantrana\Components\UserDevice\Requests\StoreDeviceTokenRequest;

class ApiUserController extends BaseController
{
    /**
     * @var AuthEngine - Auth Engine
     */
    protected $authEngine;

    /**
     * @var UserEngine - User Engine
     */
    protected $userEngine;

    /**
     * Constructor.
     *
     * @param  AuthEngine  $userEngine - User Engine
     *-----------------------------------------------------------------------*/
    public function __construct(AuthEngine $authEngine, UserEngine $userEngine)
    {
        $this->authEngine = $authEngine;
        $this->userEngine = $userEngine;
    }

    /**
     * Authenticate user based on post form data.
     *
     * @param object LoginRequest $request
     * @return json object
     *---------------------------------------------------------------- */
    public function loginProcess(LoginRequest $request)
    {
        $processReaction = $this->authEngine->processLogin($request);

        return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Prepare user signup
     *
     * @return json object
     *---------------------------------------------------------------- */
    public function prepareSignUp()
    {
        // $processReaction = $this->userEngine->prepareSignupData();

        // return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Prepare user signup
     *
     * @return json object
     *---------------------------------------------------------------- */
    public function processSignUp(UserSignUpRequest $request)
    {
        // $processReaction = $this->userEngine->userSignUpProcess($request->all());

        // return $this->processResponse($processReaction, [], [], true);
    }    

    /**
     * Process logout
     *
     * @return json object
     *-----------------------------------------------------------------------*/
    public function logout(CommonPostRequest $request)
    {
        $processReaction = $this->authEngine->processLogout($request);

        return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Mobile: send OTP email for password reset.
     */
    public function requestNewPassword(CommonClearPostRequest $request)
    {
        $processReaction = $this->authEngine->processRequestNewPassword($request->all());
        return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Mobile: verify OTP and reset password.
     */
    public function processResetPasswordWithOtp(CommonPostRequest $request)
    {
        $processReaction = $this->authEngine->processResetPasswordWithOtp($request->all());
        return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Store User Device Token.
     *
     *-----------------------------------------------------------------------*/
    public function storeUserDeviceToken(StoreDeviceTokenRequest $request)
    {
        $processReaction = $this->userEngine->processStoreUserDeviceToken($request->only('device_token', 'device_id', 'device_type'));

        return $this->processResponse($processReaction, [], [], true);
    }

    /**
     * Get current vendor subscription / plan info.
     *
     *-----------------------------------------------------------------------*/
    /**
     * Get available subscription plans
     *
     * @return json
     */
    public function subscriptionPlans()
    {
        return response()->json([
            'reaction' => 1,
            'reaction_code' => 1,
            'data' => [
                'plans' => getPaidPlans(),
            ],
        ]);
    }

    public function subscriptionInfo()
    {
        $planDetails = vendorPlanDetails('contacts');
        $freePlan = getFreePlan();
        $subscription = getVendorCurrentActiveSubscription(getVendorId());

        $features = [];
        $featureKeys = ['contacts', 'campaigns', 'bot_replies', 'bot_flows', 'contact_custom_fields', 'system_users', 'ai_chat_bot', 'api_access'];

        foreach ($featureKeys as $key) {
            $details = vendorPlanDetails($key);
            $limit = $details['plan_feature_limit'] ?? 0;
            // description not included in vendorPlanDetails return — read from config directly
            $description = getFreePlan("features.$key.description") ?: $key;
            $features[] = [
                'key'         => $key,
                'description' => $description,
                'limit'       => $limit,
            ];
        }

        return response()->json([
            'reaction' => 1,
            'reaction_code' => 1,
            'data' => [
                'plan_title'      => $planDetails['plan_title'] ?? 'Free',
                'plan_type'       => $planDetails['plan_type'] ?? 'free',
                'has_active_plan' => $planDetails['has_active_plan'] ?? false,
                'ends_at'         => ($subscription && isset($subscription->ends_at)) ? $subscription->ends_at : null,
                'features'        => $features,
            ],
        ]);
    }
}
