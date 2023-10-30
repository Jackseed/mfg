import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'fr'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? frText = '',
  }) =>
      [enText, frText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final language = locale.toString();
    return FFLocalizations.languages().contains(
      language.endsWith('_')
          ? language.substring(0, language.length - 1)
          : language,
    );
  }

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // C_GameView
  {
    'trnriys0': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // A_HomePage
  {
    'zd3bzna3': {
      'en': 'New match',
      'fr': 'Nouvelle partie',
    },
    '5upd8f28': {
      'en': 'Ranked game',
      'fr': 'Partie classée',
    },
    'hehegkwb': {
      'en': 'You need to have a Crew for ranked games',
      'fr': 'Il vous faut un Crew pour classer des parties',
    },
    'bfqx9xex': {
      'en': 'log out v0.6',
      'fr': 'déconnexion 0.6',
    },
    'pyibog7d': {
      'en': 'Play',
      'fr': 'Jouer',
    },
  },
  // B_GameForm
  {
    'o662oct6': {
      'en': 'New Game',
      'fr': 'Nouvelle partie',
    },
    '7f8twg17': {
      'en': 'Player 1',
      'fr': 'Joueur 1',
    },
    'i82gvk1q': {
      'en': 'VS',
      'fr': 'VS',
    },
    'kasj223y': {
      'en': 'Player 2',
      'fr': 'Joueur 2',
    },
    'b7er5pp3': {
      'en': 'Start',
      'fr': 'C\'est parti !',
    },
  },
  // A_CrewMenu
  {
    'v93oi4a3': {
      'en': 'Start a crew',
      'fr': 'Créer un crew',
    },
    'wi0rsx03': {
      'en': 'Create a Crew',
      'fr': 'Créer un crew',
    },
    '6msyzyxf': {
      'en': 'Join a crew',
      'fr': 'Rejoindre un Crew',
    },
    'v8dhrn7h': {
      'en': 'Games',
      'fr': 'Parties',
    },
    '92cwdwwx': {
      'en': 'History, analytics, creation',
      'fr': 'Historique, stats, création',
    },
    '55ijx7mw': {
      'en': 'DECKS',
      'fr': 'DECKS',
    },
    's0pib50g': {
      'en': 'Create, edit, stats',
      'fr': 'Créer, modifier, stats',
    },
    'tku5z5bn': {
      'en': 'Crew',
      'fr': 'Crew',
    },
  },
  // D_CrewmateList
  {
    'zouiyeow': {
      'en': 'Your username',
      'fr': 'Votre pseudo',
    },
    'xhrsuzii': {
      'en': 'Edit your name',
      'fr': 'Modifiez votre pseudo',
    },
    '40jsitp6': {
      'en': 'Invite your crewmates',
      'fr': 'Invitez vos crewmates',
    },
    'ey75tson': {
      'en': 'Share your crew with your friends!',
      'fr': 'Partagez votre crew à vos amis !',
    },
    'owngt56f': {
      'en': 'They will need this code to join your crew.',
      'fr': 'Ils auront besoin de ce code pour vous rejoindre.',
    },
    'xr32d46k': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // C1_DeckList
  {
    '8oyacj3o': {
      'en': 'DECKS',
      'fr': 'DECKS',
    },
    'cqwy149j': {
      'en': 'You don\'t have any deck yet',
      'fr': 'Vous n\'avez pas de deck',
    },
    'bikcre9j': {
      'en': 'Create one with the ➕ button below',
      'fr': 'Créez-en un avec le bouton ➕ plus bas',
    },
    'xyd4oyif': {
      'en': 'Add deck',
      'fr': 'Ajouter un deck',
    },
    'jvapusl5': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // B2_AddMatchup
  {
    'risdwrnn': {
      'en': 'ADD A GAME',
      'fr': 'Ajouter une partie',
    },
    'd9ayc0tq': {
      'en': 'Player 1',
      'fr': 'Joueur 1',
    },
    'fggxmxjw': {
      'en': 'Score',
      'fr': 'Score',
    },
    'cavg68at': {
      'en': 'VS',
      'fr': 'VS',
    },
    'ozjsfqhl': {
      'en': 'Player 2',
      'fr': 'Joueur 2',
    },
    'eyh6tn4g': {
      'en': 'Score',
      'fr': 'Score',
    },
    '1r82hx9g': {
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
  },
  // B3_MatchupList
  {
    '1q1aupjz': {
      'en': 'Matchups',
      'fr': 'Matchups',
    },
    'kpx4xw60': {
      'en': 'Add match',
      'fr': 'Ajouter un match',
    },
    'yvhaduyg': {
      'en': 'Subtext',
      'fr': '',
    },
    'ef15o1vt': {
      'en': '\$11.00',
      'fr': '',
    },
    '14t0g7bt': {
      'en': 'Title',
      'fr': '',
    },
    'a9x1vv1d': {
      'en': 'Subtext',
      'fr': '',
    },
    'vf0k1ld3': {
      'en': '\$11.00',
      'fr': '',
    },
    '26cbbx1d': {
      'en': 'Title',
      'fr': '',
    },
    'n2wy7zo6': {
      'en': 'Subtext',
      'fr': '',
    },
    '6wbv64r3': {
      'en': '\$11.00',
      'fr': '',
    },
    '29dd47xq': {
      'en': 'Title',
      'fr': '',
    },
    'ymfiiv74': {
      'en': 'Subtext',
      'fr': '',
    },
    '0nv5w0vv': {
      'en': '\$11.00',
      'fr': '',
    },
    'o3eh2zm5': {
      'en': 'Title',
      'fr': '',
    },
    'uode1x21': {
      'en': 'Subtext',
      'fr': '',
    },
    'rmh0j3e5': {
      'en': '\$11.00',
      'fr': '',
    },
    'f9kjmie6': {
      'en': 'Title',
      'fr': '',
    },
    'lhyzm8t9': {
      'en': 'Subtext',
      'fr': '',
    },
    '0pptxyoe': {
      'en': '\$11.00',
      'fr': '',
    },
    'f5s9h70j': {
      'en': 'Decks',
      'fr': 'Decks',
    },
    'mpktfrt6': {
      'en': 'Option 1',
      'fr': '',
    },
    'wxo7v8rv': {
      'en': 'You don\'t have any matchup yet',
      'fr': 'Vous n\'avez pas encore de matchup',
    },
    'bikscpls': {
      'en': 'Create your first match with the ➕ button below',
      'fr': 'Créez un premier match avec le bouton ➕plus bas',
    },
    'vr9l0d9q': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // B4_MatchupView
  {
    'b4plnj9y': {
      'en': 'Add match',
      'fr': 'Ajouter un match',
    },
    'p5su1ews': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // C2_GameList
  {
    '14kzysds': {
      'en': 'Add match',
      'fr': 'Ajouter un match',
    },
    'v66m1pgk': {
      'en': 'Subtext',
      'fr': '',
    },
    'b9k5iyqf': {
      'en': '\$11.00',
      'fr': '',
    },
    '177r7ubx': {
      'en': 'Title',
      'fr': '',
    },
    'efwe3xtv': {
      'en': 'Subtext',
      'fr': '',
    },
    '0t2lrwdk': {
      'en': '\$11.00',
      'fr': '',
    },
    '78tcpgnf': {
      'en': 'Title',
      'fr': '',
    },
    'yew4zh4j': {
      'en': 'Subtext',
      'fr': '',
    },
    '03j36l45': {
      'en': '\$11.00',
      'fr': '',
    },
    'a1lq78u7': {
      'en': 'Title',
      'fr': '',
    },
    '664z8a06': {
      'en': 'Subtext',
      'fr': '',
    },
    '42b6e7n7': {
      'en': '\$11.00',
      'fr': '',
    },
    'ef8tvr7y': {
      'en': 'Title',
      'fr': '',
    },
    'j49goc4j': {
      'en': 'Subtext',
      'fr': '',
    },
    'pbrd3ljf': {
      'en': '\$11.00',
      'fr': '',
    },
    'p91j0bd1': {
      'en': 'Title',
      'fr': '',
    },
    'lvqbhrmu': {
      'en': 'Subtext',
      'fr': '',
    },
    'ivqrylq9': {
      'en': '\$11.00',
      'fr': '',
    },
    'iw7cix4e': {
      'en': 'Decks',
      'fr': 'Decks',
    },
    'vi7doon9': {
      'en': 'Option 1',
      'fr': 'Option 1',
    },
    'f00ryjwc': {
      'en': 'Home',
      'fr': '',
    },
  },
  // EntryPage
  {
    'uou39pwv': {
      'en': 'Welcome to Magic Friends Gatherings',
      'fr': 'Bienvenue sur Magic Friends Gatherings',
    },
    'jclt3vgr': {
      'en':
          'MFG counts life during duels and enables you to keep track of the games with your friends. Eventually know what\'s the best deck!',
      'fr':
          'MFG vous permet de compter les pv lors d\'un duel et d\'enregistrer les résultats de vos parties. Vous pourrez enfin dire quel est le meilleur deck !',
    },
    'oxkk54ln': {
      'en': 'Get started',
      'fr': 'C\'est parti !',
    },
  },
  // D_About
  {
    'jqtmsa2l': {
      'en': 'About',
      'fr': 'A propos',
    },
    'ktwe4qm6': {
      'en': 'What\'s that?',
      'fr': 'C\'est quoi ça ?',
    },
    'p8z88xid': {
      'en':
          'MFG is an app created out of a love for both Magic and coding. It appears that this one is in fact made with no-coding tool (using FlutterFlow); it would have been open source otherwise. ',
      'fr':
          'MFG est une app créée par amour pour Magic et le code. Celle-ci a en fait été réalisée en no-code (FlutterFlow), sinon elle aurait été open-source.',
    },
    '6z8msqpl': {
      'en':
          'I started MFG after a spirited debate with my friends about the ranking of our decks. Eventually it doesn\'t have any MMR system but it should give us a start of an answer. And I do hope it will have one someday.',
      'fr':
          'Je me suis lancé dans MFG après un débat animé avec mes amis pour savoir comment se classaient nos decks les uns des autres. Finalement l\'app n\'a pas de système de MMR mais elle nous donne un début de réponse. Et j\'espère bien qu\'elle en aura un un jour. ',
    },
    'v65dwj8b': {
      'en':
          'If you have any inquiries, bug reports, new feature suggestions or just want to send me some kind words, please reach out to this address: jack@jackseed.dev.',
      'fr':
          'Si vous avez une question, trouvé un bug, des idées d\'améliorations ou si vous voulez tout simplement m\'envoyer un mot gentil, vous pouvez m\'écrire à cette adresse: jack@jackseed.dev.',
    },
    'mk07mwd4': {
      'en': 'Credits',
      'fr': 'Crédits',
    },
    'uqfbkt8b': {
      'en': 'Icons - ',
      'fr': 'Icônes - ',
    },
    'lqgd8ecn': {
      'en': 'TheNounProject',
      'fr': 'TheNounProject',
    },
    'rzg2jc8f': {
      'en': 'Opening animation - ',
      'fr': 'Animation d\'ouverture - ',
    },
    '14cpd0zp': {
      'en': 'LivingCardMTG',
      'fr': 'LivingCardMTG',
    },
    'fvf5itiz': {
      'en': 'Incredible API - ',
      'fr': 'API incroyable - ',
    },
    '9gjm85ls': {
      'en': 'ScryFall',
      'fr': 'ScryFall',
    },
    '3kfsi3eb': {
      'en': 'Spirited debates - ',
      'fr': 'Débats animés - ',
    },
    '11odnkx0': {
      'en': 'JellyFish, Mog, Canard',
      'fr': 'JellyFish, Mog, Canard',
    },
    'ti4hiid1': {
      'en': 'Totem card - ',
      'fr': 'Carte totem - ',
    },
    'd4rmzjxx': {
      'en': 'Demigod of Revenge',
      'fr': 'Demi-dieu de la revanche',
    },
    '3ox0nxxt': {
      'en': 'Copyright',
      'fr': 'Copyright',
    },
    'gb0fyp7i': {
      'en':
          'Magic Friends Gatherings is unofficial Fan Content permitted under the Fan Content Policy. Not approved/endorsed by Wizards. Portions of the materials used are property of Wizards of the Coast. ©Wizards of the Coast LLC.',
      'fr':
          'MFG est un contenu de fan non officiel autorisé dans le cadre de la Politique des contenus de fans. Ni approuvé, ni promu par Wizards. Certaines parties des matériaux utilisés sont la propriété de Wizards of the Coast. ©Wizards of the Coast LLC.',
    },
    '2qtkt4s9': {
      'en': 'Home',
      'fr': 'Accueil',
    },
  },
  // DeckForm
  {
    '1ehdr4fj': {
      'en': 'NEW DECK',
      'fr': 'NOUVEAU DECK',
    },
    'knpd4bkz': {
      'en': 'Deck name',
      'fr': 'Nom du deck',
    },
    '2o9dm8v4': {
      'en': '',
      'fr': '',
    },
    'r1tsialq': {
      'en': 'Type the name you want',
      'fr': 'Tapez le nom de votre choix',
    },
    'j233lymk': {
      'en': 'Avatar selection',
      'fr': 'Choix de l\'avatar',
    },
    '8elg5isn': {
      'en': 'Random card',
      'fr': 'Carte aléatoire',
    },
    '197t4btp': {
      'en': 'Random card',
      'fr': 'Carte aléatoire',
    },
    '37yhvz7t': {
      'en': 'Card search',
      'fr': 'Recherche de carte',
    },
    'rfkcb5xm': {
      'en': 'Card search',
      'fr': 'Recherche de carte',
    },
    '0ou25rex': {
      'en': '',
      'fr': '',
    },
    '4y7jf1r1': {
      'en': 'Type a card name to search',
      'fr': 'Tapez le nom d\'une carte à chercher',
    },
    's8z357ih': {
      'en': '',
      'fr': '',
    },
    'n9szxckm': {
      'en': 'We couldn\'t find this card',
      'fr': 'Impossible de trouver cette carte',
    },
    '940nz249': {
      'en': 'Try to spell it differently or find another one',
      'fr': 'Essayer de l\'écrire autrement ou cherchez-en une autre',
    },
    'c2uagd1d': {
      'en': 'Deck owner',
      'fr': 'Propriétaire du deck',
    },
    'fuz1fad9': {
      'en': 'Select your colors',
      'fr': 'Sélectionnez vos couleurs',
    },
    'hqgzwgzm': {
      'en': 'Select your background',
      'fr': 'Sélectionniez votre arrière-plan',
    },
    'elbpjfvc': {
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
    '8corzr86': {
      'en': 'A name is required',
      'fr': 'Un nom est requis',
    },
    'qtgatewo': {
      'en': 'Please choose an option from the dropdown',
      'fr': 'Choisissez une option dans cette liste',
    },
    'kjx5o0jf': {
      'en': 'Field is required',
      'fr': 'Ce champs est requis',
    },
    'ahajj93w': {
      'en': 'Please choose an option from the dropdown',
      'fr': 'Choisissez une option dans cette liste',
    },
  },
  // CrewmateForm
  {
    'ca58hcsu': {
      'en': 'Type your crewmate name',
      'fr': 'Choisissez son pseudo',
    },
    'i027ud27': {
      'en': 'Username is required',
      'fr': 'Un pseudo est requis',
    },
    'zws9wruf': {
      'en': 'Username is required',
      'fr': 'Un pseudo est requis',
    },
    'p3aa6r6m': {
      'en': 'Please choose an option from the dropdown',
      'fr': '',
    },
    'elbpjfvc': {
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
  },
  // CrewmateSelect
  {
    '12c3n924': {
      'en': 'Option 1',
      'fr': 'Option 1',
    },
    'pfd6rjvo': {
      'en': 'Select a player',
      'fr': 'Sélectionnez un joueur',
    },
    'wsp2rzui': {
      'en': 'Search for an item...',
      'fr': 'Chercher une option...',
    },
    'xn2lrhzj': {
      'en': 'Add a Crewmate',
      'fr': 'Ajouter un crewmate',
    },
  },
  // DeckSelect
  {
    '8hocaqpf': {
      'en': 'Option 1',
      'fr': 'Option 1',
    },
    'j6riey0q': {
      'en': 'Search for an item...',
      'fr': 'Chercher une option...',
    },
  },
  // CrewForm
  {
    '0ou25rex': {
      'en': '',
      'fr': '',
    },
    'j7yh8p6k': {
      'en': 'What\'s your crew name?',
      'fr': 'Comment s\'appelle votre crew ?',
    },
    'qgc02r02': {
      'en': '',
      'fr': '',
    },
    'xcd8pnzr': {
      'en': 'What\'s your pseudo?',
      'fr': 'Quel est votre pseudo ?',
    },
    'dpwcurjk': {
      'en': 'Let\'s go!',
      'fr': 'C\'est parti !',
    },
    'r7masohh': {
      'en': 'Field is required',
      'fr': 'Ce champ est obligatoire',
    },
    '8vwdg36w': {
      'en': 'Crew name is between 1 to 20 characters',
      'fr': 'Votre nom de Crew peut faire entre 1 et 20 caractères',
    },
    'rmf270e0': {
      'en': 'Crew name is between 1 to 20 characters',
      'fr': 'Votre nom de Crew peut faire entre 1 et 20 caractères',
    },
    'cu3sk3zw': {
      'en': 'Please choose an option from the dropdown',
      'fr': 'Veuillez choisir une option de la liste',
    },
    'pugezzni': {
      'en': 'Field is required',
      'fr': 'Ce champ est obligatoire',
    },
    'waugnw6n': {
      'en': 'User name is between 1 to 20 characters',
      'fr': 'Votre pseudo peut faire entre 1 et 20 caractères',
    },
    'epmyfwo3': {
      'en': 'User name is between 1 to 20 characters',
      'fr': 'Votre pseudo peut faire entre 1 et 20 caractères',
    },
    'mmo37f9j': {
      'en': 'Please choose an option from the dropdown',
      'fr': '',
    },
  },
  // CrewmateList
  {
    '7egxaj1d': {
      'en': 'Your crewmates',
      'fr': 'Vos crewmates',
    },
    '068litq8': {
      'en': 'Add a Crewmate',
      'fr': 'Ajouter un crewmate',
    },
    'gqe6012i': {
      'en': 'New Crewmate',
      'fr': 'Nouveau Crewmate',
    },
    'l8drops2': {
      'en': 'Edit crewmate',
      'fr': 'Modification d\'un crewmate',
    },
  },
  // DeckEdit
  {
    'kdwk6d3d': {
      'en': 'Deck name',
      'fr': 'Nom du deck',
    },
    'oe1in0os': {
      'en': '',
      'fr': '',
    },
    '0ji0ap7m': {
      'en': 'Type the name you want',
      'fr': 'Tapez le nom de votre choix',
    },
    'l0wukdd2': {
      'en': 'Avatar selection',
      'fr': 'Choix de l\'avatar',
    },
    'v4zc42n1': {
      'en': 'Random card',
      'fr': 'Carte aléatoire',
    },
    'i9pcxxk5': {
      'en': 'Random card',
      'fr': 'Carte aléatoire',
    },
    'k0vq10k5': {
      'en': 'Card search',
      'fr': 'Recherche de carte',
    },
    'v1cmthhn': {
      'en': 'Card search',
      'fr': 'Recherche de carte',
    },
    '1fol50t1': {
      'en': '',
      'fr': '',
    },
    'rrezwu56': {
      'en': 'Type a card name to search',
      'fr': 'Tapez le nom d\'une carte à chercher',
    },
    '4m6m5cx3': {
      'en': '',
      'fr': '',
    },
    'nf215ray': {
      'en': 'We couldn\'t find this card',
      'fr': 'Impossible de trouver cette carte',
    },
    'czuk8xy4': {
      'en': 'Try to spell it differently or find another one',
      'fr': 'Essayer de l\'écrire autrement ou cherchez-en une autre',
    },
    'j5qq0thq': {
      'en': 'Select your colors',
      'fr': 'Sélectionnez vos couleurs',
    },
    '17vkpzai': {
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
    '39l2i3vb': {
      'en': 'A name is required',
      'fr': 'Un nom est requis',
    },
    'xyoipvrd': {
      'en': 'Please choose an option from the dropdown',
      'fr': 'Choisissez une option dans cette liste',
    },
    'z2nxisek': {
      'en': 'Field is required',
      'fr': 'Ce champs est requis',
    },
    'lhjynft1': {
      'en': 'Please choose an option from the dropdown',
      'fr': 'Choisissez une option dans cette liste',
    },
  },
  // DeckView
  {
    'x8wz0s6u': {
      'en': 'Edit a deck',
      'fr': 'Modifier le deck',
    },
    'u0i2ln3j': {
      'en': ' - ',
      'fr': ' - ',
    },
  },
  // JoinCrew
  {
    'w6nopoq7': {
      'en': 'Join a crew',
      'fr': 'Rejoindre un crew',
    },
    'wm86oe7s': {
      'en': 'Ask your crewmate for the code inside their crew settings and ',
      'fr':
          'Demandez à vos crewmates le code de partage dans les paramètres du crew et ',
    },
    'm23n7sf0': {
      'en': 'paste it here.',
      'fr': 'copiez-le ici.',
    },
    '472z6rnq': {
      'en': '',
      'fr': '',
    },
    '35s3nc73': {
      'en': 'Paste your crew code',
      'fr': 'Copiez vode code de crew ici',
    },
    '39jlts1j': {
      'en': 'Join',
      'fr': 'Rejoindre',
    },
  },
  // SelectCrewmate
  {
    'twpp7myp': {
      'en': 'Crewmate selection',
      'fr': 'Sélection du joueur',
    },
    'jykel7yl': {
      'en': 'Select your player',
      'fr': 'Sélectionnez votre joueur',
    },
    'txbsr4g3': {
      'en': '(you can change your nickname later)',
      'fr': '(vous pourrez changer votre pseudo plus tard)',
    },
    'orrnpuii': {
      'en': 'No option',
      'fr': 'Aucune option',
    },
    'l4xd3pmn': {
      'en': 'Or add it if it\'s missing',
      'fr': 'Ou créez-le',
    },
    '019o280q': {
      'en': 'New Crewmate',
      'fr': 'Ajouter un équipier',
    },
    '8ul4j5vv': {
      'en': 'All good!',
      'fr': 'C\'est bon !',
    },
  },
  // emptyComponent
  {
    'e21e95f3': {
      'en': 'Seems you don’t have any crewmates',
      'fr': 'Vous n\'avez pas de crewmates',
    },
    'n52wxs9l': {
      'en':
          'Create your crewmates with the ➕ button above and they will be listed here.',
      'fr':
          'Créez vos crewmates avec le bouton ➕ au-dessus et ils seront listés ici.',
    },
    'plab1m34': {
      'en': 'Browse Menu',
      'fr': '',
    },
  },
  // Miscellaneous
  {
    '34wnly2c': {
      'en': 'Button',
      'fr': 'C\'est tout bon',
    },
    '4duqobb8': {
      'en': 'Choose a deck name',
      'fr': 'Où avez-vous joué ? (facultatif)',
    },
    '2l8hvz13': {
      'en': 'Create a Deck',
      'fr': '',
    },
    '6gl8bwbo': {
      'en': 'Player 1',
      'fr': 'Sélectionnez votre nom dans la liste',
    },
    '7or33nlq': {
      'en': 'Decks',
      'fr': 'Decks',
    },
    '67tli14p': {
      'en': 'Save',
      'fr': 'Sauvegarder',
    },
    'pkeqlpwx': {
      'en': 'Start a crew',
      'fr': 'Créer un crew',
    },
    'wszgexls': {
      'en': '',
      'fr': '',
    },
    'dpjx9l8p': {
      'en': '',
      'fr': '',
    },
    '081ci83j': {
      'en': '',
      'fr': '',
    },
    '8py14loq': {
      'en': '',
      'fr': '',
    },
    '4bh143bp': {
      'en': '',
      'fr': '',
    },
    '7elxzevk': {
      'en': '',
      'fr': '',
    },
    'r35qi2gr': {
      'en': '',
      'fr': '',
    },
    'h6dfvhd2': {
      'en': '',
      'fr': '',
    },
    'n0kya6qu': {
      'en': '',
      'fr': '',
    },
    'p23l7tkj': {
      'en': '',
      'fr': '',
    },
    'm0fe4qf5': {
      'en': '',
      'fr': '',
    },
    'thrbagsm': {
      'en': '',
      'fr': '',
    },
    'ilnc7bva': {
      'en': '',
      'fr': '',
    },
    'cj5nhelq': {
      'en': '',
      'fr': '',
    },
    'v1to2a7z': {
      'en': '',
      'fr': '',
    },
    'wcmht7v1': {
      'en': '',
      'fr': '',
    },
    'ellnulbq': {
      'en': '',
      'fr': '',
    },
    'l6tvbz1k': {
      'en': '',
      'fr': '',
    },
    '1q9fmy1v': {
      'en': '',
      'fr': '',
    },
    'zefrajju': {
      'en': '',
      'fr': '',
    },
    '655v34yq': {
      'en': '',
      'fr': '',
    },
    'xwz6my6a': {
      'en': '',
      'fr': '',
    },
    'e8xt0l1f': {
      'en': '',
      'fr': '',
    },
  },
].reduce((a, b) => a..addAll(b));
