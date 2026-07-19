class LanguagePack {
  const LanguagePack._();

  static const Map<String, String> materialSentence = {
    'block': 'en blocs',
    'brick': 'en briques',
    'concrete': 'en béton',
    'plasterboard': 'en plaques de plâtre',
    'wood': 'en bois',
    'pvc': 'en PVC',
    'aluminium': 'en aluminium',
    'steel': 'en acier',
  };

  static const Map<String, String> coveringSentence = {
    'paint': "recouvert d'un enduit sous peinture",
    'wallpaper': "recouvert d'un papier peint",
    'fiberglass': "recouvert d'une fibre de verre",
    'tiles': "revêtu d'un carrelage",
    'parquet': "revêtu d'un parquet",
    'laminate': "revêtu d'un stratifié",
    'vinyl': "revêtu d'un revêtement vinyle",
    'lvt': "revêtu d'un revêtement LVT",
    'carpet': "revêtu d'une moquette",
  };

  static const Map<String, String> conditionSentence = {
    'perfect': "en excellent état d'entretien",
    'good': "en bon état d'entretien",
    'fair': "présentant un état d'usage normal",
    'poor': "en mauvais état",
  };
}