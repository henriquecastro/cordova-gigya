Cordova Gigya
================

[Cordova](http://cordova.apache.org/) plugin that handles Gigya integration for mobile (iOS and Android) apps. Uses the native Gigya SDK and native Facebook SDK (latest 3.x release, 4.x is not supported).

## Prerequisites

### iOS

Cordova Gigya uses the latest 3.x release of the [FacebookSDK](https://developers.facebook.com/docs/ios/download). This version is included in this repo (`src/ios/FacebookSDK.framework`) and will be automatically linked to the XCode Project.

### Android

On Android it is mandatory ([REF](http://developers.gigya.com/display/GD/Android#Android-LoggingintheUser)) to use the native Facebook integration. The Facebook SDK 4.7.0 is defined as a requirement and will automatically be installed when compiling your project.

Be sure to define [add](http://developers.gigya.com/display/GD/Android#Android-AddingFacebookNativeLogin) and [activate](http://developers.gigya.com/display/GD/Facebook#Facebook-Phase2-ConfiguringFacebook'sApplicationKeysinGigya'sWebsite) the Native Facebook Login.

## Installing the plugin

Install this plugin using `cordova plugin add`:

```
cordova plugin add https://github.com/henriquecastro/cordova-gigya --variable FB_APP_NAME=<facebook app name> --variable FB_APP_ID=<facebook app id> --save
```

The `--save` option will persist the entered `FB_APP_NAME` and `FB_APP_ID` values in `config.xml`

Note that your `package.json` file won't be updated _([bug report](https://github.com/driftyco/ionic-cli/issues/359))_ and you'll have to manually update the `cordovaPlugins` section of it:

```
{
    "locator": "https://github.com/henriquecastro/cordova-gigya",
    "id": "us.platan.gigya"
}
```

## Uninstalling the plugin

Uninstall this plugin using `cordova plugin remove`:

```
cordova plugin remove us.platan.gigya
```

##Usage

The plugin has the following methods:

* [initialize](#initialize)
* [showLoginUI](#showloginui)
* [login](#login)
* [logout](#logout)
* [sendRequest](#sendrequest)
* [getSession](#getsession)

***


### initialize
Initializes the Gigya SDK and sets your partner API key.

###### Parameters

- **api_key** (string): The Gigya Site api key

###### Example

```js
cordova.plugins.CordovaGigya.initialize(apiKey)
```

### showLoginUI
Displays a provider selection dialog, allowing the user to login to any of the supported providers.

###### Parameters

- **providers** (array): *optional* An array of providers name strings that should be displayed on the UI. The list also defines the order in which the icons will be presented. 
- **params** (object): *optional* login optional parameters, refer to the gigya native sdk reference to get the posible values.
- **successCallback** (function): Called with user info data
- **failureCallback** (function): Called with error response

###### Example

```js
cordova.plugins.CordovaGigya.showLoginUI(
    ['twitter', 'facebook'],
    {
        cid: "context id"
    },
    function(user){
        console.log(user);
    },
    function(error){
        console.log(error)
    })
```

### login
Login the user to a specified provider.

###### Parameters

- **provider** (string): the provider's name that will be used for authenticating the user, e.g. "facebook", "twitter", etc.
- **params** (object): *optional* login optional parameters, refer to the gigya native sdk reference to get the posible values.
- **successCallback** (function): Called with user info data
- **failureCallback** (function): Called with error response

###### Example

```js
cordova.plugins.CordovaGigya.login(
    "twitter", 
    null,
    function(user){
        console.log(user);
    },
    function(error){
        console.log(error)
    })
```

### logout
Logs out from Gigya and clears the saved session.

###### Parameters

- **successCallback** (function): Called after logged out
- **failureCallback** (function): *(IOS only)* Called with error response

###### Example

```js
cordova.plugins.CordovaGigya.logout(
    function(){
        console.log("logged out");
    },
    function(error){
        console.log("ios error");
        console.log(error);
    })
```

### sendRequest
Sends a request to Gigya server. This method is used for invoking any of the methods supported by [Gigya's REST API][gigya-api].

###### Parameters

- **method** (string): Name of the method to be called
- **params** (object): *optional* Optional parameters for methods that require them
- **successCallback** (function): Called with request response
- **failureCallback** (function): Called with error response

###### Example

```js
cordova.plugins.CordovaGigya.sendRequest(
    "socialize.getSessionInfo",
    {
        provider: "twitter"
    },
    function(user){
        console.log(user);
    },
    function(error){
        console.log(error)
    })
```

[gigya-api]: http://wiki.gigya.com/030_API_reference/020_REST_API

### getSession
Retrieves the current session.

###### Parameters

- **successCallback** (function): Called with session token
- **failureCallback** (function): Called when error

###### Example

```js
cordova.plugins.CordovaGigya.getSession(
    function(token){
        console.log(token);
    },
    function(){
        console.log()
    })
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Credits

`cordova-gigya` was originally built by [platanus](http://platan.us). This fork is maintained by [Bramus](http://www.bram.us/)

Thank you [contributors](https://github.com/bramus/cordova-gigya/graphs/contributors)!

## License

Apache License Version 2.0.
