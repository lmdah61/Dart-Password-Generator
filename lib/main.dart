import 'dart:convert';
import 'dart:math';

import 'package:chat_gpt_api/app/chat_gpt.dart';
import 'package:chat_gpt_api/app/model/data_model/completion/completion_request.dart';
import 'package:http/http.dart' as http;

const String _chatGPTapiKey =
    'YOUR_API_KEY';

Future<int> getRandomNumber(int range) async {
  // Gets a random number from Random.org
  final response = await http.get(Uri.parse(
      'https://www.random.org/integers/?num=1&min=1&max=$range&col=1&base=10&format=plain&rnd=new'));

  if (response.statusCode == 200) {
    final number = int.parse(response.body.trim());
    return number;
  } else {
    throw Exception('Failed to generate random number');
  }
}

Future<String> getRandomWord() async {
  // Gets a random english word from 'random-word-api'
  final response =
      await http.get(Uri.parse('https://random-word-api.herokuapp.com/word'));

  if (response.statusCode == 200) {
    final jsonResult = json.decode(response.body);
    final word = jsonResult[0];
    return word;
  } else {
    throw Exception('Failed to load random word');
  }
}

String addSpecialCharacter(String finalPhrase) {
  final specialChars = ['!', '@', '#', '\$', '%', '&', '?'];

  // Gets a random char from the list
  final randomCharIndex = Random().nextInt(specialChars.length);
  final specialChar = specialChars[randomCharIndex];

  // Randomly decides if the character should be added at the front or at the end of the phrase
  final addAtBeginning = Random().nextBool();

  return addAtBeginning
      ? "$specialChar$finalPhrase"
      : "$finalPhrase$specialChar";
}

Future<String> replaceLetterWithNumber(String phrase) async {
  final leetMap = {
    'a': '4',
    'b': '8',
    'e': '3',
    'l': '1',
    'o': '0',
    's': '5',
    't': '7'
  };

  // Convert the phrase to a list of characters
  List<String> chars = phrase.split('');

  // Attempts to find an appropriate character to be replaced
  int attempts = 0;
  while (attempts < 100) {
    // Generate a random index to replace
    int indexToReplace = await getRandomNumber(chars.length - 1);

    // Get the character at the randomly generated index
    String charToReplace = chars[indexToReplace].toLowerCase();

    // Check if the character can be replaced according to leetMap
    if (leetMap.containsKey(charToReplace)) {
      // Replace the character with the leetMap value
      chars[indexToReplace] = leetMap[charToReplace]!;
      break;
    }

    attempts++;
  }

  // Join the characters back together into a string and return either the modified phrase or the original phrase
  return chars.join('');
}

Future<String> generatePhrase(String randomWord) async {
  final chatGpt = ChatGPT.builder(token: _chatGPTapiKey);

  final prompt = '''
Generate a memorable 4-word phrase with the word $randomWord. Each word should start with an uppercase letter, and there should be no spaces, quotes, punctuation, symbols, or special characters. The phrase should resemble a classic internet post.
''';

  final chatGPTanswer = await chatGpt.textCompletion(
    request: CompletionRequest(
      prompt: prompt,
      maxTokens: 256,
    ),
  );

  final randomPhrase = chatGPTanswer?.choices?.first.text;
  if (randomPhrase == null) {
    throw Exception('Failed to generate random phrase');
  }

  return randomPhrase.trim();
}

Future<void> main() async {
  try {
    // gets a random word from an online API
    final randomWord = await getRandomWord();

    // gets a random phrase from chatGPT featuring the random word
    final phrase = await generatePhrase(randomWord);

    // add numbers and special characters
    final finalPhrase = await replaceLetterWithNumber(phrase);
    final password = addSpecialCharacter(finalPhrase);

    print(password);
  } catch (e) {
    print('Failed to generate password: $e');
  }
}
