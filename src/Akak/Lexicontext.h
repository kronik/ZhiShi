/*
 * Copyright 2011 Rubnatak Holding
 *
 * Licensed under the Lexicontext terms of use (the "Terms of Use");
 * you may not use this file except in compliance with the Terms of Use.
 * You may obtain a copy of the Terms of Use at
 * 
 *    http://www.lexicontext.com/terms.html
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the Terms of Use is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the Terms of Use for the specific language governing permissions and
 * limitations under the Terms of Use.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * The following constants define the parts of speech that Lexicontext handles
 */
extern NSString * const kLexicontextNoun;
extern NSString * const kLexicontextVerb;
extern NSString * const kLexicontextAdjective;
extern NSString * const kLexicontextAdverb;

/**
 * The Lexicontext class provides an offline dictionary for iOS applications.
 * The dictionary data files are bundled with the app and are therefore always available for the
 * app.
 */
@interface Lexicontext : NSObject {

    NSString *touchableWordsURLScheme;    

}



/**
 * The custom-URL scheme of the dictionary word hyperlinks. 
 * When a word definition is looked up via one of the definitionAsHTMLFor: methods, each word in the 
 * HTML can be turned into a hyperlink. This is useful, for example, if you want your users to be able 
 * to lookup definitions of the words that comprise the definition.
 * Assuming you specified the custom-scheme in your app's info.plist file, when the user touches a word, 
 * iOS asks the app's delegate to open a resource identified by the URL. This technique gives you a chance 
 * to respond to a user's action. In a typical scenario, you would open the dictionary definition for 
 * the touched word. 
 * Note that if a custom scheme is not specified, the words in the definition will not be replaced with 
 * hyperlinks.
 */
@property(retain, nonatomic) NSString *touchableWordsURLScheme;


/**
 * The Lexicontext dictionary is implemented as a singleton and is accessible via this class method. 
 * By default, the shared dictionary is instantiated using the dictionary resource bundle that was bundled
 * with the application.  
 * @return the singleton dictionary instance (or nil if something went wrong during the initialization).
 */
+ (Lexicontext *)sharedDictionary;


/**
 * This factory method creates the Lexicontext dictionary singleton (if necessary) using the specified 
 * data bundle. This is useful if you don't want to bundle Lexicontext's data together with your app 
 * as a resource (for example, you may want to reduce the app's original archive size). 
 * That is, you want your app to be installed without the dictionary and then download the data bundle 
 * separately, perhaps in response to a user action. 
 * To use this method, the data bundle should already be available locally. You can either take care
 * of the bundle download yourself, or you can use the free Lexicontext Fetch add-on that performs the 
 * download->save->unzip sequence for you.
 *
 * If the Lexicontext instance was already initialized earlier without specifying a custom bundle path (for 
 * example, you already invoked the default sharedDictionary method) or if you specified earlier a different 
 * custom path and looked up words, invoking this method will simply re-initialized Lexicontext with the 
 * new path.
 *
 * @param fullPath the full path to Lexicontext's data bundle (typically the path to LexicontextAssets.bundle). 
 *        Passing nil tells Lexicontext to try to initialize from a resource bundle that was packaged with the 
 *        app
 * @return the singleton dictionary instance (or nil if something went wrong during the initialization).
 */
+ (Lexicontext *)sharedDictionaryWithBundlePath:(NSString *)fullPath;


/**
 * This factory method creates the Lexicontext dictionary singleton (if necessary) using the specified 
 * path for the auxilary word-list file (see the documentation of the method addDefinitionFor::: for more
 * details). You can use this method if you don't want the auxiliary plist file to be saved in the app's 
 * documents folder (the default location).
 *
 * @param wordlistPath the full path to file that should be used as the auxiliary plist file.
 * @return the singleton dictionary instance (or nil if something went wrong during the initialization).
 */
+ (Lexicontext *)sharedDictionaryWithAuxWordlistPath:(NSString *)wordlistPath;


/**
 * @return a plain-text definition for the input word
 * @param word the word to look up in the dictionary
 */
- (NSString *)definitionFor:(NSString *)word;


/**
 * @return true if there's a definition for the word in the dictionary
 * @param word the word to look up in the dictionary
 */
- (BOOL)containsDefinitionFor:(NSString *)word;


/**
 * This method returns a word definition in HTML, formatted using the default settings: black text over 
 * white background in 20-pixel Georgia fonts.
 * 
 * @return an HTML version of the definition for the input word, using the default formatting settings.
 * @param word the word to look up in the dictionary.
 */
- (NSString *)definitionAsHTMLFor:(NSString *)word;


/**
 * This method returns a word definition in HTML, formatted using the default  settings (black text 
 * over white background in Georgia fonts), except for the font size.
 * 
 * @return an HTML version of the definition for the input word, using a custom font size.
 * @param word the word to look up in the dictionary.
 * @param definitionBodyFontSize the font size (in pixels) to use for formatting the definition's text.
 */
- (NSString *)definitionAsHTMLFor:(NSString *)word withDefinitionBodyFontSize:(CGFloat)bodyFontSize;


/**
 * This method returns a word definition in HTML, formatted using custom settings. 
 * Note that more customization is possible by using the definitionAsHTMLFor:withStyleSheet: method.
 * 
 * @return an HTML version of the definition for the input word.
 * @param word the word to look up in the dictionary.
 * @param textColor the text color to use, using the CSS color values. See, for example: 
 *        http://www.w3schools.com/css/css_colors.asp 
 * @param backgroundColor the text color to use, using the CSS color values. See, for example: 
 *        http://www.w3schools.com/css/css_colors.asp 
 * @param bodyFontFamily the font family to use for the definition's text. For example Georgia, Arial,
 *        Courier, etc.               
 * @param definitionBodyFontSize the font size (in pixels) to use for the definition's text.
 */
- (NSString *)definitionAsHTMLFor:(NSString *)word 
                    withTextColor:(NSString *)textColor 
                  backgroundColor:(NSString *)backgroundColor 
         definitionBodyFontFamily:(NSString *)bodyFontFamily
           definitionBodyFontSize:(CGFloat)bodyFontSize;


/**
 * This method returns a word definition in HTML format with custom stylesheet.
 * The supplied stylesheet should include entries for the selectors: 'body', 'p.definition_body' and 'a'
 * 
 * For example, the following stylesheet is will show the definition in white text, over transparent background:
 *
 * <style type='text/css'>
 *     body {   
 *         background-color: transparent;    
 *         color:#FFFFFF
 *     }
 *     p.definition_body {   
 *         font-family:'Arial';   
 *         font-size:25px
 *     }
 *     a {   
 *         color: #FFFFFF;   
 *         text-decoration: none;
 *     }         
 * </style>
 *
 *
 * @return an HTML version of the definition for the input word, using a custom font size.
 * @param word the word to look up in the dictionary.
 * @param definitionBodyFontSize the font size (in pixels) to use for the definition's text.
 */
- (NSString *)definitionAsHTMLFor:(NSString *)word withStyleSheet:(NSString *)css;


/**
 * This method returns the definition of the word, structured as an NSDictionary.
 * The dictionary keys are the parts-of-speech for the input word (noun, verb, etc). Legal values for the keys are 
 * the strings: kLexicontextNoun, kLexicontextVerb, kLexicontextAdjective and kLexicontextAdverb.
 * The corresponding value for each key is an NSArray of NSStrings, where each string holds one possible definition 
 * for that part of speech.
 *
 * For example, the call [[Lexicontext sharedDictionary] definitionAsDictionaryFor:@"clear"] will return the full version of the 
 * following structure:
 *
 * {
 *   Adjective => ("readily apparent to the mind...", ... , "characterized by ease and quickness in perceiving...");
 *   Adverb => ("completely...", "in an easily perceptible manner...");
 *   Noun => ("the state of being free of suspicion...", "a clear or unobstructed...");
 *   Verb =< ("rid of obstructions...", ... , "free (the throat) by...");
 *  }
 *
 * @return the definition for the input word as NSDictionary
 * @param word the word to look up in the dictionary
 */
- (NSDictionary *)definitionAsDictionaryFor:(NSString *)word;

/**
 * This method returns a set of synonyms of the given word, structured as an NSDictionary.
 * The dictionary keys are the parts-of-speech for the input word (noun, verb, etc). 
 * The corresponding value for each key is an NSArray of NSArrays of NSStrings. Each array of strings contains
 * a set of synonyms for that part of speech.
 * The set of synonyms for each part of speech are ordered by estimated frequency of use. 
 * 
 * For example, the call 
 *
 *    NSDictionary *synset = [[Lexicontext sharedDictionary] thesaurusFor:@"test"]; 
 *
 * will return the following structure:
 *
 * {
 *   Noun = (
 *     (trial, trial run, test, tryout),
 *     (test, mental test, mental testing, psychometric test),
 *     (examination, exam, test),
 *     (test, trial),
 *     (test, trial, run)
 *   );
 *   Verb =  (
 *     (test, prove, try, try out, examine, essay),
 *     (screen, test),
 *     (quiz, test)
 *   );
 * }
 *
 * @return the set of synonyms for the input word as NSDictionary
 * @param word the word to look up in the dictionary
 */
- (NSDictionary *)thesaurusFor:(NSString *)word;

/**
 * This method returns all the entries in the dictionary that begin with the given prefix.
 * The result is structured as an NSDictionary where the dictionary keys are the parts-of-speech for the input word (noun, verb, etc). 
 * The corresponding value for each key is an NSArray of NSStrings with all the results for that part of speech. 
 * 
 * For example, the call 
 *
 *    NSDictionary *words = [dictionary wordsWithPrefix:word]; 
 *
 * will return the following structure:
 *
 * {
 *   Adjective =  (test (adj), testaceous, testamentary, ...);
 *   Adverb = (test (adv), testily);
 *   Noun = (test (noun), test-cross, test-tube baby, test ban, ...);
 *   Verb = (test (verb), test drive, test fly, testify);
 * } 
 *
 * @return all the entries in the dictionary that begin with the given prefix.
 * @param prefix the prefix to use for the search
 */
- (NSDictionary *)wordsWithPrefix:(NSString *)prefix;

/**
 * This method returns all the entries in the dictionary that contain the given search string.
 * The result is structured as an NSDictionary where the dictionary keys are the parts-of-speech for the input word (noun, verb, etc). 
 * The corresponding value for each key is an NSArray of NSStrings with all the results for that part of speech. 
 * 
 * For example, the call 
 *
 *    NSDictionary *words = [dictionary wordsWithPrefix:word]; 
 *
 * will return the following structure:
 *
 * {
 *   Adjective = (test (adj), greatest, latest, ...);
 *   Adverb = (test (adv), fastest, testily);
 *   Noun = (test (noun), acid test, agglutination test, ...);
 *   Verb = (test (verb), attest, contest, ...);
 * }
 *
 * @return all the entries in the dictionary that contain the given search string.
 * @param searchString the string to use for the search
 */

- (NSDictionary *)grep:(NSString *)searchString;

/**
 * This methods allows you to add word definitions to the dictionary at runtime.
 * You can add multiple definitions for the same word (for example, when the word belongs to multiple parts of speech) by
 * calling this methods multiple times for the same word with different definitions.
 *
 * Note that newly added words are *not* merged into the core dictionary files. They are instead kept in an auxiliary plist file,
 * named lexicontext_ext_words.plist. Lexicontext arrives with a default auxiliary plist file that is included in the 
 * LexicontextAssets resource. The file is copied from the bundle to the app's Documents folder when the dictionary is initialized 
 * (if a file with that name already exist in the Documents folder the file is *not* replaced and the existing file is used 
 * instead). Words that you add at runtime by calling this method will be added to the Documents folder copy.
 * If you prefer, you can add words to the list by editing the default lexicontext_ext_words.plist that resides in the resource 
 * bundle, before you build your app instead of doing it programmatically from your app's code. If you choose to manually edit the 
 * file, please make sure that you follow the file format precisely, otherwise the auxiliary list will not be able to be loaded 
 * from the file and will be initialized to an empty list instead.
 * Please note also that The auxiliary list is loaded into memory when the dictionary is initialized and therefore it is only 
 * intended to hold a few hundred words. Adding too many words can impact the performance of the Lexicontext dictionary (and your 
 * app).
 * For obvious reasons, the method imageNetIdFor: will return nil for words that only exist in the auxiliary list (such words are
 * not included in WordNet and thus don't have a WordNet ID).
 *
 * @param word the word to add to the dictionary. If the input word is nil, the dictionary will not be modified.
 * @param definition a definition for the new word. The definition may be set to nil to signify a legal word with unknown meaning.
 * @param pos the word's part-of-speech. Legal values for this parameter are Adjective, Adverb, Noun, Verb, Conjunction, Pronoun, 
 *        Preposition & Unknown. The part-of-speech may be set to nil in which case the Unknown part of speech will be used. 
 * @return the full definition for the input word as an NSDictionary
 */
- (NSDictionary *)addDefinitionFor:(NSString *)word withDefinition:(NSString *)definition andPartOfSpeech:(NSString *)pos;

/**
 * This method lets you get the WordNet ID for a given word, as defined by image-net.org
 * With this ID use can use ImageNet's various image-related APIs.
 *
 * Background: ImageNet is an image dataset organized according to the WordNet hierarchy. 
 * ImageNet (http://www.image-net.org) define the concept of a "WordNet ID" which is simply a concatenation 
 * of the word's part of speech first character ('n' for noun, 'v' for verb, etc) and the SYNSET OFFSET in WordNet. 
 * Please note that currently ImageNet only support nouns, so this method is only useful for nouns.
 * You can find more information about the ImageNet API and their definition of WordNet IDs at http://image-net.org/download-API
 * 
 * @param word the word whose WordNet ID is required
 * @return the WordNet ID for the input word (or nil if the word can not be found in the dictionary)
 */
- (NSString *)imageNetIdFor:(NSString *)word;

/**
 * This method returns an array of URLs containing images of the given word.
 * The method uses the ImageNet web service and currently only works for nouns.
 * @param word the word whose images should be looked up
 * @return an array of NSURL objects, where each URL points to an image of the input word
 */
- (NSArray *)imageURLsFor:(NSString *)word;

/**
 * @ returns a random word from the dictionary
 */
- (NSString *)randomWord; 


/**
 * Given a Lexicontext custom URL that was passed to your app's delegate, this method extracts the word 
 * that was touched.
 *
 * When a word definition is looked up via one of the definitionAsHTMLFor: methods, each word in the 
 * resulting definition HTML can be turned into a custom-scheme based hyperlink. This is useful if 
 * you want your users to be able to lookup the definitions for unfamiliar words that show up in 
 * another word definition.
 * The scheme that Lexicontext uses when it generates the links is specified via the touchableWordsURLScheme 
 * property. Assuming you specified the custom-scheme in your app's info.plist file, when the user 
 * touches a word, iOS asks the delegate to open a resource identified by URL. This gives you a chance 
 * to respond to a user's action. In a typical scenario, you would open the dictionary definition for 
 * that word. Given the URL that was passed to your app, this method extracts the word that was touched.
 * Note that if the custom scheme is not specified, the words in the definition will not be replaced with 
 * hyperlinks.
 *
 * @param url the custom URL that was passed to your app.
 */
+ (NSString *)touchedWord:(NSURL *)url;


@end
