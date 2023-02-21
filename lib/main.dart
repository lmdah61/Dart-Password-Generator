import 'dart:convert';
import 'dart:math';

import 'package:chat_gpt_api/app/chat_gpt.dart';
import 'package:chat_gpt_api/app/model/data_model/completion/completion_request.dart';
import 'package:http/http.dart' as http;

String _chatGPTapiKey = 'YOUR_API_KEY';

Future<int> getRandomNumber() async {
  final response = await http.get(Uri.parse(
      'https://www.random.org/integers/?num=1&min=0&max=9&col=1&base=10&format=plain&rnd=new'));

  if (response.statusCode == 200) {
    final number = int.parse(response.body.trim());
    return number;
  } else {
    throw Exception('Failed to generate random number');
  }
}

Future<String> getRandomWord() async {
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

String getRandomSpecialCharacter() {
  const specialChars = ['!', '@', '#', '\$', '%', '&', '?'];

  final random = Random();
  final index = random.nextInt(specialChars.length);

  return specialChars[index];
}

Future<void> main() async {
  final randomWord = await getRandomWord();

  final randomNumber = await getRandomNumber();

  final randomSpecialCharacter = getRandomSpecialCharacter();

  final chatGpt = ChatGPT.builder(token: _chatGPTapiKey);

  final prompt = '''
Generate a 4-word phrase resembling a memorable internet post, featuring the word $randomWord.
Start each word with an uppercase letter and omit spaces.
Print the final phrase without any additional explanation, no quotes, no punctuation, no symbols.
''';

  final chatGPTanswer = await chatGpt.textCompletion(
    request: CompletionRequest(
      prompt: prompt,
      maxTokens: 256,
    ),
  );

  final randomPhrase = chatGPTanswer?.choices?.first.text!;

  final prompt2 = '''
Replace one character from this String: $randomPhrase with the number $randomNumber. Keep the String readable.
''';

  final chatGPTanswer2 = await chatGpt.textCompletion(
    request: CompletionRequest(
      prompt: prompt2,
      maxTokens: 256,
    ),
  );

  final finalPassword = chatGPTanswer2?.choices?.first.text!;

  print('$finalPassword$randomSpecialCharacter');
}
