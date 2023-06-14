List<String> zipCodes = new List<String>{
    '35175', '35175', '60417', '60417', '60417', '01010', '01931', '01931', '01931', '02140', '02140', '23897'
};

for(String currentZipCode : zipCodes){
    currentZipCode
}

String input = 'Lucid Motors is an electric vehicle automotive company';

List<String> inputWordList = input.split(' ');
Map<String,Integer> inputByVowelCount = new Map<String,Integer> ();

System.debug('\n ** inputWordList ' + inputWordList);

Integer countOfVowels = 0;

for(String currentString : inputWordList){
    //how many occurance of same vowel per word 
    //missing
    if(currentString.contains('a')){
        countOfVowels ++;
    } 
    if(currentString.contains('e')){
        countOfVowels ++;
    }
    if(currentString.contains('i')){
        countOfVowels ++;
    }
    if(currentString.contains('o')){
        countOfVowels ++;
    }
    if(currentString.contains('u')){
        countOfVowels ++;
    }
    inputByVowelCount.put(currentString, countOfVowels);
    countOfVowels = 0;
}

System.debug('\n ** *inputByVowelCount ' +inputByVowelCount);






