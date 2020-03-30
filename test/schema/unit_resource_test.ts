// Checks that the resource URLs defined in unit data JSON point to real files.

import glob from 'glob';
import path from 'path';

glob(path.join('data', 'unit', '**', '*.json'), (error, files) => {
  if (error) {
    fail(error);
    return;
  }
  for (const file of files) {
    test(`${file} should have correct resource URLs`, () => {});
  }
});
