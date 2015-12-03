package us.cordova.gigya;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.Log;

import com.gigya.socialize.GSObject;
import com.gigya.socialize.GSResponse;
import com.gigya.socialize.GSResponseListener;
import com.gigya.socialize.android.GSAPI;
import com.gigya.socialize.android.GSSession;
import com.gigya.socialize.android.GSPluginFragment;
import com.gigya.socialize.android.event.GSLoginUIListener;
import com.gigya.socialize.android.event.GSDialogListener;
import com.gigya.socialize.android.event.GSPluginListener;

public class CordovaGigya extends CordovaPlugin {

    private static final String TAG = "CordovaGigya";
    private JSONObject responseRAAS;

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        
        Log.d(TAG, action);

        if ("initialize".equals(action)) {

            GSAPI.getInstance().initialize(cordova.getActivity(), args.getString(0), args.getString(1));
            callbackContext.success();

            return true;

        }
        else if ("showLoginUI".equals(action)) {

            // Get the providers
            JSONArray providers = args.optJSONArray(0);

            // options
            JSONObject paramsJSON = args.optJSONObject(1);

            // Prepare params object
            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            else {
                params = new GSObject();
            }

            // Providers
            if(providers != null &&  providers.length() > 0){
                params.put("enabledProviders", providers.join(",").replace("\"", ""));
            }

            // Present the Login user interface.
            GSAPI.getInstance().showLoginUI(params, new GSLoginUIListener() {
                @Override
                public void onLoad(Object context) {
                    Log.d(TAG, "Gigya loginUI was loaded");
                }

                @Override
                public void onError(GSResponse response, Object context) {
                    Log.d(TAG, "Gigya loginUI had an error - " + response.getErrorMessage());
                    JSONObject data = getData(response);
                    callbackContext.error(data);
                }

                @Override
                public void onClose(boolean canceled, Object context) {
                    Log.d(TAG, "Gigya loginUI was closed");
                }

                @Override
                public void onLogin(String provider, GSObject user, Object context) {
                    Log.d(TAG, "Gigya loginUI has logged in");
                    JSONObject data = getData(user);
                    callbackContext.success(data);
                }
            }, null);

            return true;
        } else if ("login".equals(action)) {

            // Get the providers
            String provider = args.optString(0);

            // options
            JSONObject paramsJSON = args.optJSONObject(1);

            // Prepare params object
            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            else {
                params = new GSObject();
            }

            // Provider
            if (provider != null && provider != "") {
                params.put("provider", provider);
            }

            // Present the Login user interface.
            try {
                GSAPI.getInstance().login(params, new GSResponseListener() {
                    @Override
                    public void onGSResponse(String method, GSResponse response, Object context) {
                        JSONObject data = getData(response);
                        if (response.getErrorCode() == 0) {
                            callbackContext.success(data);
                        } else {
                            callbackContext.error(data);
                        }
                    }
                }, null);
            } catch (Exception e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }

            return true;
        } else if ("getSession".equals(action)) {

            GSSession session = GSAPI.getInstance().getSession();
            if(session != null) {
                callbackContext.success(session.toString());
            } else {
                callbackContext.error(new String());
            }
            

            return true;
        } else if("loginUserWithPassword".equals(action)) {
            JSONObject paramsJSON = args.optJSONObject(0);

            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

            GSAPI.getInstance().sendRequest("accounts.login", params, new GSResponseListener() {
                @Override
                public void onGSResponse(String method, GSResponse response, Object context) {
                    JSONObject data = getData(response);
                    
                    if (response.getErrorCode() == 0) {
                        try {
                            
                            JSONObject sessionInfo = data.getJSONObject("sessionInfo");
                            String sessionToken = sessionInfo.getString("sessionToken");
                            String sessionSecret = sessionInfo.getString("sessionSecret");
                            GSSession currentSession = new GSSession(sessionToken, sessionSecret);
                            if(currentSession != null) {
                                GSAPI.getInstance().setSession(currentSession);
                            }

                        } catch (JSONException e) {
                            // TODO Auto-generated catch block
                            e.printStackTrace();
                        }
                        
                        callbackContext.success(data);
                    } else {
                        callbackContext.error(data);
                    }
                }
            }, null);

            return true;

        } 
        else if("getCurrentUser".equals(action)) {
            JSONObject paramsJSON = args.optJSONObject(0);

            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

            GSAPI.getInstance().sendRequest("socialize.getUserInfo", params, new GSResponseListener() {
                @Override
                public void onGSResponse(String method, GSResponse response, Object context) {
                    JSONObject data = getData(response);
                    
                    if (response.getErrorCode() == 0) {                        
                        callbackContext.success(data);
                    } else {
                        callbackContext.error(data);
                    }
                }
            }, null);

            return true;
        }
        else if("addConnectionToProvider".equals(action)) {
            
            String provider = args.optString(0);

            JSONObject paramsJSON = args.optJSONObject(1);

            paramsJSON.put("provider", provider);

            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

            GSAPI.getInstance().addConnection(params, new GSResponseListener() {
                @Override
                public void onGSResponse(String method, GSResponse response, Object context) {
                    JSONObject data = getData(response);

                    if (response.getErrorCode() == 0) {                        
                        callbackContext.success(data);
                    } else {
                        callbackContext.error(data);
                    }
                }
            }, null);

            return true;
        }
        else if ("sendRequest".equals(action)){

            String method = args.getString(0);
            JSONObject paramsJSON = args.optJSONObject(1);

            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }

            GSAPI.getInstance().sendRequest(method, params, new GSResponseListener() {
                @Override
                public void onGSResponse(String method, GSResponse response, Object context) {
                    JSONObject data = getData(response);
                    if (response.getErrorCode() == 0) {
                        callbackContext.success(data);
                    } else {
                        callbackContext.error(data);
                    }
                }
            }, null);

            return true;
        }
        else if ("logout".equals(action)){

            GSAPI.getInstance().logout();
            callbackContext.success();

            return true;
        }
        //ScreenSets
        else if("showScreenSet".equals(action)){

            // Get the screenset
            String screenSet = args.optString(0);

            // options
            JSONObject paramsJSON = args.optJSONObject(1);

            // Prepare params object
            GSObject params = null;

            if(paramsJSON != null){
                try {
                    params = new GSObject(paramsJSON.toString());
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
            }
            else {
                params = new GSObject();
            }

            //Screenset
            params.put("screenSet", screenSet);

            GSAPI.getInstance().showPluginDialog("accounts.screenSet", params, new GSPluginListener() {
                @Override
                public void onLoad(GSPluginFragment gsPluginFragment, GSObject gsObject) {
                    Log.d(TAG, "Gigya screenSet was loaded");
                }

                @Override
                public void onError(GSPluginFragment gsPluginFragment, GSObject error) {
                    
                    Log.d(TAG, "Gigya screenSet had an error - " + error.toJsonString());
                    JSONObject data = getData(error);
                    callbackContext.error(data);

                }

                @Override
                public void onEvent(GSPluginFragment gsPluginFragment, GSObject gsObject) {

                    if(gsObject.getString("eventName", "").equals("afterSubmit") && (!gsObject.getString("response", "").isEmpty() || !gsObject.getString("data", "").isEmpty())) {
                        responseRAAS = getData(gsObject);
                    }
                    else if(gsObject.getString("eventName", "").equals("hide")) {

                        //Finish?
                        if(gsObject.getString("reason", "").equals("finished") && responseRAAS.length() > 0) {
                            callbackContext.success(responseRAAS);
                        }
                        else {
                            JSONObject data = getData(gsObject);
                            callbackContext.error(data);
                        }
                        
                    }
                }
            }, new GSDialogListener() {
                @Override
                public void onDismiss(boolean b, GSObject gsObject) {

                }
            });

            return true;
        }
        return false;  // Returning false results in a "MethodNotFound" error.
    }

    private JSONObject getData(GSResponse response){
        JSONObject data = null;
        try {
            data = new JSONObject(response.getData().toJsonString());
            data.put("errorDetails", response.getErrorDetails());
            data.put("errorCode", response.getErrorCode());
            data.put("errorMessage", response.getErrorMessage());
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return data;
    }

    private JSONObject getData(GSObject response){
        JSONObject data = null;
        try {
            data = new JSONObject(response.toJsonString());
        } catch (JSONException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return data;
    }
}
