// Disease library — South African livestock common diseases

interface Disease {
  id: string;
  name: string;
  species: string[];
  symptoms: string[];
  treatment: string;
  prevention: string;
}

const LIBRARY: Disease[] = [
  {
    id: "d001",
    name: "Foot and Mouth Disease",
    species: ["cattle", "goat"],
    symptoms: ["blisters on feet", "blisters on mouth", "lameness", "drooling", "fever", "loss of appetite"],
    treatment: "Supportive care and isolation. Notifiable disease — report immediately to authorities.",
    prevention: "Annual vaccination, strict biosecurity, movement controls.",
  },
  {
    id: "d002",
    name: "Heartwater (Cowdriosis)",
    species: ["cattle", "goat"],
    symptoms: ["fever", "loss of appetite", "convulsions", "circling", "high-stepping gait", "sudden death"],
    treatment: "Tetracycline antibiotics — early treatment is critical.",
    prevention: "Tick control, regular dipping, graze in low-risk areas.",
  },
  {
    id: "d003",
    name: "Lumpy Skin Disease",
    species: ["cattle"],
    symptoms: ["skin nodules", "fever", "nasal discharge", "loss of condition", "lameness"],
    treatment: "Supportive care; antibiotics for secondary infections.",
    prevention: "Vaccination, insect vector control.",
  },
  {
    id: "d004",
    name: "Bluetongue",
    species: ["goat", "cattle"],
    symptoms: ["fever", "blue tongue", "facial swelling", "nasal discharge", "lameness", "mouth ulcers"],
    treatment: "Supportive care, rest, antibiotics for secondary infections.",
    prevention: "Vaccination, midge vector control.",
  },
  {
    id: "d005",
    name: "Orf (Contagious Ecthyma)",
    species: ["goat"],
    symptoms: ["scabs on lips", "lesions around mouth", "pustules", "weight loss"],
    treatment: "Allow scabs to heal naturally; apply antiseptic to lesions.",
    prevention: "Vaccination, avoid contact with infected animals.",
  },
  {
    id: "d006",
    name: "Brucellosis",
    species: ["cattle", "goat"],
    symptoms: ["abortions in late pregnancy", "stillbirths", "retained placenta", "infertility"],
    treatment: "No treatment — cull infected animals. Notifiable disease.",
    prevention: "Vaccination (S19/RB51 for cattle), testing before introduction.",
  },
  {
    id: "d007",
    name: "Bovine Respiratory Disease (BRD)",
    species: ["cattle"],
    symptoms: ["fever", "nasal discharge", "coughing", "laboured breathing", "depression", "loss of appetite"],
    treatment: "Antibiotics (florfenicol, tulathromycin) under vet guidance.",
    prevention: "Reduce stress, proper ventilation, vaccination.",
  },
  {
    id: "d008",
    name: "Pneumonia",
    species: ["goat"],
    symptoms: ["coughing", "nasal discharge", "laboured breathing", "fever", "lethargy"],
    treatment: "Antibiotics and supportive care under vet guidance.",
    prevention: "Dry housing, reduce overcrowding and stress.",
  },
  {
    id: "d009",
    name: "Mastitis",
    species: ["cattle", "goat"],
    symptoms: ["swollen udder", "hot or hard quarter", "blood in milk", "clots in milk", "reduced milk yield"],
    treatment: "Intramammary antibiotics, milking out, anti-inflammatory drugs.",
    prevention: "Teat dipping, dry cow therapy, clean milking practices.",
  },
  {
    id: "d010",
    name: "Blackleg",
    species: ["cattle"],
    symptoms: ["sudden lameness", "swelling in leg", "crepitation on palpation", "high fever", "sudden death"],
    treatment: "High-dose penicillin if caught early; often fatal.",
    prevention: "Annual vaccination of calves.",
  },
];

export const diseaseService = {
  getLibrary: (species?: string): Disease[] => {
    if (species) return LIBRARY.filter((d) => d.species.includes(species));
    return LIBRARY;
  },

  detect: (symptoms: string[]): Array<Disease & { confidence: number; matchedSymptoms: string[] }> => {
    const lowerSymptoms = symptoms.map((s) => s.toLowerCase());
    const scored = LIBRARY.map((disease) => {
      const matched = lowerSymptoms.filter((s) =>
        disease.symptoms.some((ds) => ds.toLowerCase().includes(s) || s.includes(ds.toLowerCase())),
      );
      return {
        ...disease,
        confidence: disease.symptoms.length > 0 ? matched.length / disease.symptoms.length : 0,
        matchedSymptoms: matched,
      };
    });
    return scored
      .filter((d) => d.confidence > 0)
      .sort((a, b) => b.confidence - a.confidence)
      .slice(0, 5);
  },
};
