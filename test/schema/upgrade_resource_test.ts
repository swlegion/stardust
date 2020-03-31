// Checks that the resource URLs defined in upgrade data JSON point to real files.

import fs from 'fs-extra';
import glob from 'glob';
import path from 'path';
import { Upgrade } from '../../lib/types/schema';

const files = glob.sync(path.join('data', 'upgrade', '**', '*.json'));

expect.extend({
  toExist(file) {
    const pass = fs.existsSync(file);
    if (pass) {
      return {
        message: (): string => `Expected ${file} to not exist`,
        pass: true,
      };
    } else {
      return {
        message: (): string => `Expected ${file} to exist`,
        pass: false,
      };
    }
  },
});

declare global {
  // eslint-disable-next-line @typescript-eslint/no-namespace
  namespace jest {
    interface Matchers<R> {
      toExist: () => R;
    }
  }
}

for (const file of files) {
  const resolve = (to: string): string => {
    return path.join(path.dirname(file), to);
  };

  test(`${file} should have correct resource URLs`, () => {
    const json = fs.readFileSync(file, { encoding: 'UTF-8' });
    const upgrade = JSON.parse(json) as Upgrade;
    const card = path.join(path.dirname(file), upgrade.card);
    expect(card).toExist();

    if (upgrade.model) {
      const model = upgrade.model;
      const render = resolve(model.render);
      expect(render).toExist();

      const texture = model.texture;
      if (typeof texture == 'string') {
        const image = resolve(texture);
        expect(image).toExist();
      } else {
        const red = texture.red;
        const blue = texture.blue;
        expect(red).not.toBe(blue);
        const image1 = resolve(red);
        const image2 = resolve(blue);
        expect(image1).toExist();
        expect(image2).toExist();
      }
    }
  });
}
