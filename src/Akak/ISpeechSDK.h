#import <Foundation/Foundation.h>
#import <AvailabilityMacros.h>

/**
 * The error domain for the iSpeech SDK. All errors sent to delegate methods will have this error domain.
 */
extern NSString *const ISpeechErrorDomain;

/**
 * Error codes returned by the SDK. They might not all be used. If the error domain of an NSError object is ISpeechErrorDomain, compare the error code to one of the values in this enum to figure out what went wrong.
 */
enum ISpeechErrorCode {
	kISpeechErrorCodeInvalidAPIKey = 1,
	kISpeechErrorCodeUnableToConvert = 2,
	kISpeechErrorCodeNotEnoughCredits = 3,
	kISpeechErrorCodeNoActionSpecified = 4,
	kISpeechErrorCodeInvalidText = 5,
	kISpeechErrorCodeTooManyWords = 6,
	kISpeechErrorCodeInvalidTextEntry = 7,
	kISpeechErrorCodeInvalidVoice = 8,
	kISpeechErrorCodeInvalidFileFormat = 12,
	kISpeechErrorCodeInvalidSpeed = 13,
	kISpeechErrorCodeInvalidDictionary = 14,
	kISpeechErrorCodeInvalidBitrate = 15,
	kISpeechErrorCodeInvalidFrequency = 16,
	kISpeechErrorCodeInvalidAliasList = 17,
	kISpeechErrorCodeAliasMissing = 18,
	kISpeechErrorCodeInvalidContentType = 19,
	kISpeechErrorCodeAliasListTooComplex = 20,
	kISpeechErrorCodeCouldNotRecognize = 21,
	kISpeechErrorCodeInvalidLocale = 23,
	kISpeechErrorCodeModelNotSupported = 25,
	kISpeechErrorCodeModelDoesNotSupportLocale = 26,
	kISpeechErrorCodeLocaleNotSupported = 28,
	kISpeechErrorCodeOptionNotEnabled = 30,
	kISpeechErrorCodeTrialPeriodExceeded = 100,
	kISpeechErrorCodeAPIKeyDisabled = 101,
	kISpeechErrorCodeNoAPIAccess = 997,
	kISpeechErrorCodeUnsupportedOutputType = 998,
	kISpeechErrorCodeInvalidRequest = 999,
	kISpeechErrorCodeInvalidRequestMethod = 1000,
	
	/* SDK Specific Error Codes */
	kISpeechErrorCodeUserCancelled = 300,
	kISpeechErrorCodeNoInputAvailable = 301,
	kISpeechErrorCodeNoInternetConnection = 302,
	kISpeechErrorCodeSDKIsBusy = 303
};

/**
 * The class used to interface with the iSpeech Cloud, providing developers with text-to-speech and speech recognition services for their apps.
 *
 * The SDK will not automatically stop speaking or recognizing speech when your application goes into the background. You will have to call `ISpeechCancelListen` and `ISpeechStopSpeaking` when your application delegate's background methods get called.
 * @warning *Important:* Currently, the SDK will configure your application's audio session to how it needs to be to perform well. It will set the audio session category to be 'Play and Record' (`kAudioSessionCategory_PlayAndRecord`), it will enable bluetooth input (`kAudioSessionProperty_OverrideCategoryEnableBluetoothInput`), and it will force the audio session to default to the speaker, not the reciever (`kAudioSessionProperty_OverrideCategoryDefaultToSpeaker`). The SDK will also watch the `kAudioSessionProperty_AudioRouteChange` and react to that, specifically looking for when input devices become available or unavailable. If audio input becomes possible, the SDK will change the audio session category to `kAudioSessionCategory_PlayAndRecord`. If audio input becomes not possible, it will set the audio session category to `kAudioSessionCategory_MediaPlayback`.
 */
@interface ISpeechSDK : NSObject {
	
}

/**
 * To disable any of the dialogs, please contact us at sales AT ispeech DOT org.
 * 
 * This method does nothing.
 */
- (void)toDisableTheDialogContact_salesATiSpeechDOTorg;

/** @name Speech Synthesis */

/**
 * Sets the delegate that the SDK will message on speaking events. The delegate is not retained.
 *
 * Please note that this delegate should implement the `ISpeechDelegateStartedSpeaking:` and `ISpeechDelegateFinishedSpeaking:withStatus:` methods of the `ISpeechDelegate` protocol to be considered "valid" for the SDK.
 * 
 * Like `UIWebView`, you will need to set the speaking delegate to `nil` when your delegate is deallocated. This makes sure that the delegate pointer is not left dangling. If you do not do this, your application will crash, most likely due to an `EXC_BAD_ACCESS` error, because the SDK is trying to message that dangling pointer.
 *
 * It is recommended that you set a new delegate in a `UIViewController` subclass in the `-[UIViewController viewDidAppear:]` method, and set the delegate to `nil` in the `-[UIViewController viewWillDisappear:]` method to help avoid the incorrect delegate being set.
 * @warning *Important:* In the current implementation of the SDK, if you try to set a speaking delegate, and _don't_ implement both methods, the SDK will reject your delegate. This behavior is likely to change in a future release.
 * @param delegate The object that will be messaged by the SDK.
 * @return Returns the previous delegate.
 * 
 */
- (id) ISpeechSetSpeakingDone:(id)delegate;

/**
 * Sets the voice to be used for speech synthesis.
 * 
 * The voice set will be used for all subsequent speech synthesis until this method is called again with a different voice. A list of available voices is not provided with the SDK. You must supply a voice from the list of voices enabled for your API key from the developer portal. You will get an error back if you specify an invalid voice or a voice that is not enabled for your API key.
 * @param voice The name of the voice to be used.
 * @see ISpeechSpeak:
 */
- (void) ISpeechSetVoice:(NSString *)voice;

/**
 * Returns the voice currently used by the speech synthesis engine.
 * 
 * By default, this value is `nil`, which means "usenglishfemale" wil be used.
 */
- (NSString *)ISpeechVoice;

/**
 * Sets the speed to use for speech synthesis.
 * 
 * This should be a number anywhere between -10 and 10, with -10 being the slowest, and 10 being the fastest. If you provide a number larger than 10, the speed will be set to 10. Likewise, if you provide a number smaller than -10, the speed will be set to -10.
 * @param speed The new speed to set.
 */
- (void) ISpeechSetSpeed:(NSInteger)speed;

/**
 * Get the speed that's being used for speech synthesis.
 */
- (NSInteger) ISpeechSpeed;

/**
 * Speaks the given text in the voice set with `ISpeechSetVoice:`.
 *
 * Set the voice by calling `ISpeechSetVoice:` before this method is called. If no voice is specified, the SDK defaults to "usenglishfemale". A popup will be displayed while text is being spoken. A cancel button is displayed on the popup to allow the user to stop the audio. If the user does tap the cancel button, `ISpeechDelegateFinishedSpeaking:withStatus:` will be called on the speaking delegate with an `NSError` object passed into it whose code is `kISpeechErrorCodeUserCancelled`. 
 * @param text The text that should be spoken.
 * @return Returns whether the speech synthesis was started successfully (`YES`) or not (`NO`).
 * @see ISpeechStopSpeaking
 * @see ISpeechSpeak:error:
 */
- (BOOL) ISpeechSpeak:(NSString *)text;

/**
 * Speaks the given text in the voice set with `ISpeechSetVoice:`.
 * 
 * The main difference between `ISpeechSpeak:error:` and `ISpeechSpeak:` is that you will get a reference to an `NSError` object passed out through `errPtr`. Currently, the only possible error for speech synthesis would be no internet connection (`kISpeechErrorCodeNoInternetConnection`). If this method returns `NO`, check the error that is passed out for information about the error.
 * @param text The text that should be spoken.
 * @param errPtr On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object. You may specify `nil` for parameter if you do not want error information, or you can use `ISpeechSpeak:`.
 * @return Returns `YES` if the SDK was able to successfully start speaking, `NO` if it wasn't.
 * @see ISpeechSpeak:
 */
- (BOOL) ISpeechSpeak:(NSString *)text error:(NSError **)errPtr;

/**
 * Cancels any speech synthesis in progress.
 *
 * This method will cancel any audio being played, as well as kill any networking going on because of speech synthesis. The speaking delegate will not be notified when this method is called.
 * @see ISpeechSpeak:
 * @see ISpeechSpeak:error:
 */
- (void) ISpeechStopSpeaking;

/**
 * Returns whether the SDK is currently performing speech synthesis (`YES`) or not (`NO`).
 */
- (BOOL) ISpeechIsSpeaking;

/** @name Speech Recognition */

/**
 * Sets the locale to use for speech recognition.
 *
 * Most of the time, value passed is a ISO country code. To get our supported ISOs, consult "Freeform Dictation Languages" under "Speech Recognition Settings" when viewing details about a specific key.
 * @param locale The locale to set. For example, @"fr-FR" for French.
 */
- (void) ISpeechSetLocale:(NSString *)locale;

/**
 * The locale that is used for speech recognition as an ISO country code.
 */
- (NSString *) ISpeechLocale;

/**
 * Sets the model for the server to use with speech recognition.
 *
 * @param model The model for the server to use.
 */
- (void) ISpeechSetModel:(NSString *)model;

/**
 * Returns the model that is used by the server for speech recognition. If no model was set, this will return `nil`.
 */
- (NSString *)ISpeechModel;

/**
 * Cancels any speech recognition in progress.
 * @return Returns `YES` if speech recognition was cancelled, or `NO` if there was no speech recognition being performed.
 */
- (BOOL) ISpeechCancelListen ;

/**
 * *<span style="color: red;">Deprecated:</span>* This method has been marked as deprecated. You should use `ISpeechIsRecognizing` as a replacement.
 *
 * @warning *Warning:* This method has been marked as deprecated and is likely to be removed in a future release. You should migrate your code away from using this method.
 * @return Returns whether the SDK is done performing speech recognition (`YES`) or not (`NO`).
 * @see ISpeechIsRecognizing
 */
- (BOOL) ISpeechListenDone DEPRECATED_ATTRIBUTE;

/**
 * Returns the result of the last speech recognition action.
 * @see ISpeechGetRecognizeConfidence
 */
- (NSString *) ISpeechGetRecognizeResult ;

/**
 * Returns the confidence of the speech recognition request.
 *
 * The result will be a number between `0.0` and `1.0`. The higher the number, the more confident the recognizer was.
 * @see ISpeechGetRecognizeResult
 */
- (float) ISpeechGetRecognizeConfidence ;

/**
 * Returns the status of the speech recognition as returned by the server.
 * @warning *Warning:* This method has been marked as deprecated and is likely to be removed in a future release. You should migrate your code away from using this method.
 * @return Currently always returns `-1`.
 */
- (NSInteger) ISpeechGetRecognizeStatus DEPRECATED_ATTRIBUTE;

/**
 * Sets the delegate the SDK will message when speech recognition has been completed. The delegate is not retained.
 * 
 * The object passed needs to implement the `ISpeechDelegateFinishedRecognize:withStatus:result:` method of the `ISpeechDelegate` protocol to be considered valid.
 * 
 * Like `UIWebView`, you will need to set the recognizing delegate to `nil` when your delegate is deallocated. This makes sure that the delegate pointer is not left dangling. If you do not do this, your application will crash, most likely due to an `EXC_BAD_ACCESS` error, because the SDK is trying to message that dangling pointer.
 * @param delegate The object that will be messaged by the SDK on recognition events.
 * @return Returns `nil` if the given object does not implement the required method, or the previous delegate, which could also be `nil`. This behavior is likely to change in a future release.
 */
- (id) ISpeechSetRecognizeDone:(id)delegate;

/**
 * Tells the SDK that, for the next speech recognition process, to enable silence detection.
 *
 * Silence detection works by telling the SDK to wait a number seconds before trying to detect silence, and then to make sure the silence last for at least a certain length. You may want to play with different numbers to get silence detection at a point that it feels natural.
 * @param seconds How long the SDK should wait before trying to detect silence.
 * @param duration How long silence should last for it to be considered "silence".
 */
- (void) ISpeechSilenceDetectAfter:(NSTimeInterval)seconds forDuration:(NSTimeInterval)duration;

/**
 * Tells the SDK to start an untimed listen.
 * 
 * A popup dialog will be displayed to the user that shows input levels. A done button will also be placed on the popup, allowing the user to end the listening process and start the recognizing process. A cancel button is also placed on the popup if a user changes their mind. If the user does tap the cancel button, `ISpeechDelegateFinishedRecognize:withStatus:result:` will be called on the recognition delegate with an `NSError` object passed into it whose code is `kISpeechErrorCodeUserCancelled`. An audio prompt may also play before the listening actually starts.
 * 
 * Most of the time, doing an untimed listen is not what you want to do. The user could potentially not say anything at all, which would cause the SDK to keep recording until the user pressed the done button. This type of action will also have an adverse affect on battery life, as well as start sapping the user's cellular data. What you would want to do is do a timed listen, by calling `ISpeechListenThenRecognizeWithTimeout:`.
 * @return Returns `YES` if the SDK was able to start listening, or `NO` if it wasn't.
 * @see ISpeechStopListenStartRecognize
 * @see ISpeechListenThenRecognizeWithTimeout:
 * @see ISpeechStartListenWithError:
 */
- (BOOL) ISpeechStartListen;

/**
 * Tells the SDK to start an untimed listen.
 *
 * The main difference between `ISpeechStartListen` and `ISpeechStartListenWithError:` is that you will get a reference to an `NSError` object passed out through `errPtr`. Currently, there are only two possible errors: No audio input (`kISpeechErrorCodeNoInputAvailable`) and no internet connection (`kISpeechErrorCodeNoInternetConnection`). If this method returns `NO`, check the error passed out through errPtr for details about the error.
 * @param errPtr On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object. You may specify `nil` for parameter if you do not want error information, or you can use `ISpeechStartListen`.
 * @return Returns `YES` if the SDK was able to start listening, or `NO` if it wasn't.
 * @see ISpeechStartListen
 */
- (BOOL) ISpeechStartListenWithError:(NSError **)errPtr;


/**
 * Stops the listening process and starts the recognition process.
 *
 * You should call this method after you call `ISpeechStartListen` to stop listening. This will start the recognizing process 
 * @return Returns `YES` if the SDK stopped the listen and start the recognition, or `NO` if something went wrong.
 */
- (BOOL) ISpeechStopListenStartRecognize;

/**
 * Starts a timed speech recognition process in which the SDK will listen for a set time, and then start recognizing.
 * @param seconds The amount of time, in seconds, the SDK should listen for before starting recognition.
 * @return Returns `YES` if the SDK was able to start listening, or `NO` if it wasn't.
 * @see ISpeechListenThenRecognizeWithTimeout:error:
 */
- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds;

/**
 * Starts a timed speech recognition process in which the SDK will listen for a set time, and then start recognizing.
 *
 * The main difference between `ISpeechListenThenRecognizeWithTimeout:` and `ISpeechListenThenRecognizeWithTimeout:error:` is that you will get a reference to an `NSError` object passed out through `errPtr`. Currently, there are only two possible errors: No audio input (`kISpeechErrorCodeNoInputAvailable`) and no internet connection (`kISpeechErrorCodeNoInternetConnection`). If this method returns `NO`, check the error passed out through `errPtr` for details about the error.
 * @param seconds The amount of time, in seconds, the SDK should listen for before starting recognition.
 * @param errPtr On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object. You may specify `nil` for parameter if you do not want error information, or you can use `ISpeechListenThenRecognizeWithTimeout:`.
 * @return Returns `YES` if the SDK was able to start listening, or `NO` if it wasn't.
 * @see ISpeechListenThenRecognizeWithTimeout:
 */
- (BOOL) ISpeechListenThenRecognizeWithTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr;

/**
 * Adds a recognition list to the next speech recognition process. The commands are removed after the process completes;
 *
 * Recognition lists are a way for your application to add predefined commands. Instead of your application performing freeform speech recognition and parsing the resulting text, the SDK will listen for these commands, and return whichever ones match when the recognition delegate is called. From there, your application can act on those commands.
 * @warning *Important:* You should only use this method if you plan on doing a timed listen by using `ISpeechListenThenRecognizeWithTimeout:`. This method will not work on untimed listens; you will get `NO` back if you call `ISpeechStartListen` after calling this.
 * @param strings An array of commands that should be recognized.
 * @see ISpeechClearRecognitionList
 */
- (void) ISpeechAddRecognitionList:(NSArray *)strings;

/**
 * Adds a recognition list to the next speech recognition process. The commands are removed after the process completes.
 * 
 * An alias list is a quick way to add similar commands. Say you're building a voice dialer application. Rather than add a recognition list of all the persons contacts (ie, [@"call larry", @"call moe", @"call curley"]), you can call this method, like so:
 *
 * <div class="warning"><code>[ispeech ISpeechAddRecognitionAlias:@"call %STOOGES%" forList:[NSArray arrayWithObjects:@"larry", @"moe", @"curley", nil]];</code></div>
 *
 * Which will achieve the same effect, while also making it easier to create recognition lists.
 * @warning *Important:* You should only use this method if you plan on doing a timed listen by using `ISpeechListenThenRecognizeWithTimeout:`. This method will not work on untimed listens; you will get `NO` back if you call `ISpeechStartListen` after calling this.
 * @param aliasName The command that should be recognized, with the placeholder surrounded by percent signs (`%`).
 * @param strings An array of strings that would be put in the placeholder's location when recognition is performed.
 * @see ISpeechClearRecognitionList
 */
- (void) ISpeechAddRecognitionAlias:(NSString *)aliasName forList:(NSArray *)strings;

/**
 * Clears any recognition or alias lists currently present.
 * 
 * @warning If you call this after adding a recognition or alias list, but before initiating speech recognition, this will leave in boilerplate code for speech recognition, so if you call `ISpeechStartListen` or `ISpeechListenThenRecognize:separatedBy:withTimeout:`, they will fail by returning `NO`.
 */
- (void) ISpeechClearRecognitionList;

/**
 * Generate a recognition list from `stringOfWords` separated by `wordSeparator`, perform a timed listen for `seconds` seconds, then recognize.
 *
 * This method is a convenience method for clearing and existing recognition list, creating a new one, listening for a certain time, and then recognizing. This method will call `ISpeechClearRecognitionList`, `ISpeechAddRecognitionList`, and `ISpeechListenThenRecognizeFor:`.
 * @param stringOfWords A list of commands to recognize, merged into one string, and separated by a given separator.
 * @param wordSeparator The series of characters that splits `stringOfWords` up into the individual commands.
 * @param seconds The amount of time, in seconds, the SDK should listen for before starting recognition.
 * @return Returns `YES` if the SDK was able to start listening, or `NO` if it wasn't.
 */
- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds;

/**
 * Generate a recognition list from `stringOfWords` separated by `wordSeparator`, perform a timed listen for `seconds` seconds, then recognize.
 *
 * The main difference between `ISpeechListenThenRecognize:separatedBy:withTimeout:` and `ISpeechListenThenRecognize:separatedBy:withTimeout:error:` is that you will get a reference to an `NSError` object passed out through `errPtr`. Currently, there are only two possible errors: No audio input (`kISpeechErrorCodeNoInputAvailable`) and no internet connection (`kISpeechErrorCodeNoInternetConnection`). If this method returns `NO`, check the error passed out through `errPtr` for details about the error.
 * @param stringOfWords A list of commands to recognize, merged into one string, and separated by a given separator.
 * @param wordSeparator The series of characters that splits `stringOfWords` up into the individual commands.
 * @param seconds The amount of time, in seconds, the SDK should listen for before starting recognition.
 * @param errPtr On input, a pointer to an error object. If an error occurs, this pointer is set to an actual error object. You may specify `nil` for parameter if you do not want error information, or you can use `ISpeechListenThenRecognize:separatedBy:withTimeout:`.
 * @see ISpeechListenThenRecognizeWithTimeout:
 */
- (BOOL) ISpeechListenThenRecognize:(NSString *)stringOfWords separatedBy:(NSString *)wordSeparator withTimeout:(NSTimeInterval)seconds error:(NSError **)errPtr;

/**
 * Returns whether the SDK is currently performing speech recognition (`YES`) or not (`NO`).
 */
- (BOOL) ISpeechIsRecognizing;

/**
 * Allows the developer to set extra parameters that should be sent to the server.
 * 
 * The string supplied should be in the form of a query string, and the keys and values should be already URL-encoded. These parameters will be sent for both speech synthesis requests and speech recognition requests. You should only use this method if directed to do so.
 * @param params The query string that should be sent to the server during requests.
 */
- (void)ISpeechSetExtraServerParameters:(NSString *)params;

/** @name Initialization */

/**
 * The designated intializer for the `ISpeechSDK` object.
 * 
 * This method should be used instead of calling `+alloc`/`-init`, as this is the only way to pass in the needed information to the SDK. While this object will return a singleton, it is not advised that you continually call this method for every time that you need that instance. Instead, you should create a property on your application delegate, and reference that single instance every time you need to use the SDK. That way you can keep track of the object and release it when your application is terminated.
 * @warning *Important:* The instance returned from this object is _not_ autoreleased, despite the method being a class method, and the method not having "alloc", "copy", "new", or "retain" in the name. You will need to release it when you're done with it. This behavior is likely to change in a future release.
 * @param apiKey An API key provided by iSpeech through the Developer Portal.
 * @param provName The name of the company using the SDK. Most of the time, you will set this to the app's bundle identifier.
 * @param appName The name of the applicaton using the SDK. Most of the time, you will set this to the product name from the Info.plist file.
 * @param useProduction A Boolean value, specifying whether to use the Mobile Production server (`YES`) or the Mobile Development server (`NO`).
 * @return Returns an instance of the `ISpeechSDK` class.
 */
+ (ISpeechSDK *) ISpeech:(NSString *)apiKey provider:(NSString *)provName application:(NSString *)appName useProduction:(BOOL)useProduction;

@end

/**
 * The delegate of the `ISpeechSDK` must adopt the `ISpeechDelegate` protocol. These methods allow the delegate to respond to the start and completion of speech synthesis, as well as the completion of speech recognition.
 */
@protocol ISpeechDelegate
@optional

/**
 * Called when the SDK starts playing synthesized speech audio.
 *
 * This method should be implemented, along with `ISpeechDelegateFinishedSpeaking:withStatus:`, for the SDK to recognize the delegate as being valid.
 * @param ispeech The instance of the `ISpeechSDK` class that is playing audio.
 */
- (void)ISpeechDelegateStartedSpeaking:(ISpeechSDK *)ispeech;

/**
 * Called when the SDK finishes playing synthesized speech audio.
 *
 * This method should be implemented, along with `ISpeechDelegateStartedSpeaking:`, for the SDK to recognize the delegate as being valid.
 *
 * This method will be called if an error occurs, in addition to when speech synthesis completes. When that happens, `status` will point to a valid NSError isntance, instead of `nil`. You should check `status` to make sure that it is not `nil` to handle errors.
 * @param ispeech The instance of the `ISpeechSDK` class that was playing audio.
 * @param status An error associated with the speech synthesis. This will be `nil` if no error occured. This is the recommend way to perform error handling.
 */
- (void) ISpeechDelegateFinishedSpeaking:(ISpeechSDK *)ispeech withStatus:(NSError *)status;

/**
 * Notifies the delegate when the SDK has finished recognizing speech and has a text result.
 *
 * This method will be called if an error occurs, in addition to when recognition completes. When that happens, `status` will point to a valid NSError isntance, instead of `nil`. You should check `status` to make sure that it is not `nil` to handle errors.
 * @param ispeech The instance of the `ISpeechSDK` class that finished recognizing.
 * @param status An error associated with the speech recogntition. This will be `nil` if no error occured. This is the recommend way to perform error handling.
 * @param text The resulting text from the speech recognizer.
 */
- (void) ISpeechDelegateFinishedRecognize:(ISpeechSDK *)ispeech withStatus:(NSError *)status result:(NSString *)text; 

/**
 * Notifies the delegate when recording starts and stops for speech recognition.
 *
 * The delegate will get two possible values passed into `status` when this is called: `kISpeechRecordingStarted` for when recording starts, and `kISpeechRecordingStopped` for when recording has ended.
 * @param ispeech The instance of the `ISpeechSDK` class that changed state.
 * @param status The status of the SDK. Will either be `kISpeechRecordingStarted` or `kISpeechRecordingStopped`.
 */
- (void) ISpeechDelegateRecordingUpdate:(ISpeechSDK *)ispeech progress:(UInt32)status;

@end

/**
 * The different status updates associated with `-ISpeechDelegateRecordingUpdate:progress:`.
 */
enum {
	kISpeechRecordingStarted = 1,
	kISpeechRecordingStopped
};
