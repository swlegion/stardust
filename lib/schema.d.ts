// TODO: Use `json-schema-to-typescript` or similar to auto-generate.

export interface Unit {
  card: string;
  models: Array<Model>;
}

export interface Model {
  render: string;
  texture: string | TexturePair;
}

export interface TexturePair {
  red: string;
  blue: string;
}

export interface Upgrade {
  card: string;
  model?: Model;
}

export interface DataBlob {
  units: Unit[];
  upgrades: Upgrade[];
}