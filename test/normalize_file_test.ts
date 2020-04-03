// Checks that we can normalize different type of prospective file names.

import { normalizeName } from '../lib/mod/file';

test('should normalize files with punctuation', () => {
  expect(normalizeName('foo. bar')).toEqual('foo_bar');
  expect(normalizeName('foo- bar')).toEqual('foo_bar');
  expect(normalizeName('foo! bar')).toEqual('foo_bar');
  expect(normalizeName('foo: bar')).toEqual('foo_bar');
  expect(normalizeName(`foo 'bar'`)).toEqual('foo_bar');
  expect(normalizeName('foo "bar"')).toEqual('foo_bar');
});

test('should normalize files with brackets and parentheses', () => {
  expect(normalizeName(`foo (bar)`)).toEqual('foo_bar');
  expect(normalizeName('foo [bar]')).toEqual('foo_bar');
  expect(normalizeName('foo {bar}')).toEqual('foo_bar');
  expect(normalizeName('foo <bar>')).toEqual('foo_bar');
});
