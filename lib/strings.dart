import 'app_state.dart';

// All UI text. Story text will live in JSON later; 'welcome_young' / 'welcome_older' show the tier idea.
const _ui = <String, Map<Lang, String>>{
  'title': {Lang.en: 'Ghosts of the Sky', Lang.bn: 'মহাকাশের ভুলে যাওয়া বন্ধুরা'}, // placeholder title
  // Step 0 is shown in the language guessed from the device (English if none matched).
  'bubble_0': {Lang.en: 'Hi! I’m Roby! 🤖 Which language do you like?', Lang.bn: 'হাই! আমি রোবি! 🤖 তোমার কোন ভাষা পছন্দ?'},
  'bubble_1': {Lang.en: 'What’s your name, space explorer?', Lang.bn: 'তোমার নাম কী, মহাকাশ অভিযাত্রী?'},
  'bubble_2': {Lang.en: 'Nice to meet you, {name}! How old are you?', Lang.bn: 'তোমার সঙ্গে দেখা হয়ে ভালো লাগল, {name}! তোমার বয়স কত?'},
  'name_hint': {Lang.en: 'Type your name', Lang.bn: 'নাম লেখো'},
  'next': {Lang.en: 'Next', Lang.bn: 'পরের ধাপ'},
  'start': {Lang.en: 'Let’s go!', Lang.bn: 'চলো শুরু করি!'},
  'welcome_young': {
    Lang.en: 'Hi {name}! 🚀 Did you know some old space machines are resting on the Moon right now? Let’s go meet them!',
    Lang.bn: 'হাই {name}! 🚀 তুমি কি জানো, কিছু পুরোনো মহাকাশযান এখন চাঁদে বিশ্রাম নিচ্ছে? চলো, ওদের সঙ্গে দেখা করি!',
  },
  'welcome_older': {
    Lang.en: 'Welcome, {name}. Since the 1960s, NASA has left spacecraft on the Moon, on Mars and in deep space. Each one has a story. Ready to find them?',
    Lang.bn: 'স্বাগতম, {name}। ১৯৬০-এর দশক থেকে নাসা চাঁদ, মঙ্গল ও গভীর মহাকাশে বহু মহাকাশযান রেখে এসেছে। প্রতিটির আছে একটি গল্প। খুঁজে দেখতে প্রস্তুত?',
  },
  'launch': {Lang.en: 'Launch 🚀', Lang.bn: 'যাত্রা শুরু 🚀'},
  'loading': {Lang.en: 'Loading the Moon...', Lang.bn: 'চাঁদ লোড হচ্ছে...'},
  'ready': {Lang.en: 'Ready, {name}! Tap an orange dot or a button.', Lang.bn: 'প্রস্তুত, {name}! কমলা বিন্দু বা বোতামে ট্যাপ করো।'},
  'tapped': {Lang.en: 'You tapped: {x}', Lang.bn: 'তুমি ট্যাপ করেছ: {x}'},
  'arrived': {Lang.en: 'Arrived at: {x}', Lang.bn: 'পৌঁছে গেছি: {x}'},
  'load_error': {Lang.en: 'Load error: {x}', Lang.bn: 'লোড করতে সমস্যা: {x}'},
  'reset': {Lang.en: 'Reset', Lang.bn: 'রিসেট'},
  'restart_tip': {Lang.en: 'Change name, age or language', Lang.bn: 'নাম, বয়স বা ভাষা বদলাও'},
  'apollo11': {Lang.en: 'Apollo 11', Lang.bn: 'অ্যাপোলো ১১'},
  'apollo12': {Lang.en: 'Apollo 12', Lang.bn: 'অ্যাপোলো ১২'},
  'apollo17': {Lang.en: 'Apollo 17', Lang.bn: 'অ্যাপোলো ১৭'},
  // ---- Opening story: Opportunity rover, June 2018 (facts: see docs/story_opportunity.md) ----
  'story_0': {Lang.en: 'Mars. June 2018.', Lang.bn: 'মঙ্গল গ্রহ। জুন ২০১৮।'},
  'story_1': {
    Lang.en: 'A giant dust storm covers the whole planet. For months, the sky stays dark.',
    Lang.bn: 'এক বিশাল ধুলোঝড় পুরো গ্রহকে ঢেকে ফেলেছে। কয়েক মাস ধরে আকাশ অন্ধকার।',
  },
  'story_2': {
    Lang.en: 'A little robot named Opportunity, “Oppy”, runs on sunlight. Now the sunlight is gone.',
    Lang.bn: 'অপরচুনিটি নামে একটি ছোট্ট রোবট, আদর করে “অপি”, সূর্যের আলোয় চলে। এখন আর আলো নেই।',
  },
  'story_3': {
    Lang.en: 'On June 10, 2018, Oppy sent one last signal to Earth. It was numbers about low power and a dark sky. Scientists put it into words:',
    Lang.bn: '২০১৮ সালের ১০ জুন অপি পৃথিবীতে শেষবারের মতো একটি সংকেত পাঠাল। তাতে ছিল কম বিদ্যুৎ আর অন্ধকার আকাশের কিছু সংখ্যা। বিজ্ঞানীরা সেটাকে কথায় সাজালেন:',
  },
  'story_quote': {
    Lang.en: '“My battery is low and it’s getting dark.”',
    Lang.bn: '“আমার ব্যাটারি প্রায় শেষ, আর চারপাশ অন্ধকার হয়ে আসছে।”',
  },
  'story_caption': {Lang.en: 'A poetic translation of the real data.', Lang.bn: 'আসল তথ্যের একটি কাব্যিক অনুবাদ।'},
  'story_4': {
    Lang.en: 'Oppy was built to work for 90 days. It worked for almost 15 years, and helped show that Mars was once a wet world.',
    Lang.bn: 'অপিকে বানানো হয়েছিল মাত্র ৯০ দিন কাজ করার জন্য। সে কাজ করল প্রায় ১৫ বছর, আর দেখাল যে মঙ্গল একসময় পানিতে ভরা ছিল।',
  },
  'story_5': {
    Lang.en: 'Oppy is still up there. So are many other machines on the Moon, on Mars and in deep space. Come meet them!',
    Lang.bn: 'অপি এখনও মঙ্গলেই আছে। চাঁদ, মঙ্গল আর গভীর মহাকাশে আছে আরও অনেক যন্ত্র। চলো, ওদের সঙ্গে দেখা করি!',
  },
  'story_go': {Lang.en: 'Start', Lang.bn: 'শুরু করো'},
  'skip': {Lang.en: 'Skip', Lang.bn: 'এড়িয়ে যাও'},
  'battery': {Lang.en: 'Battery', Lang.bn: 'ব্যাটারি'},
};

String tr(AppState s, String key, {Map<String, String> vars = const {}}) {
  var t = _ui[key]?[s.lang] ?? key;
  vars.forEach((k, v) => t = t.replaceAll('{$k}', v));
  return t;
}

/// Numbers in Bengali digits when the app language is Bengali.
String localNum(AppState s, int n) {
  if (s.lang != Lang.bn) return '$n';
  const d = '০১২৩৪৫৬৭৮৯';
  return '$n'.split('').map((c) => d[int.parse(c)]).join();
}
