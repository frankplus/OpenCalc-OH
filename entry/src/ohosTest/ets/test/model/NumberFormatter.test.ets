import { describe, expect, it } from '@ohos/hypium';
import { CalculatorStore } from '../../../../main/ets/model/CalculatorStore';

const store: CalculatorStore = CalculatorStore.getInstance();

function fmt(input: string, expected: string, system: number = 0): void {
  expect(store.formatInput(input, system)).assertEqual(expected);
}

export default function numberFormatterTest() {
  describe('NumberFormatterTest', () => {
    it('given a decimal expression when formatting then format with grouping separator', 0, () => {
      fmt('5,000 + 5,00000', '5,000 + 500,000');
    });
    it('given a decimal number when formatting then format with grouping separator', 0, () => {
      fmt('12345', '12,345');
    });
    it('given a floating-point number when formatting then format with grouping separator and decimal separator', 0, () => {
      fmt('1234.567', '1,234.567');
    });
    it('given a large number when formatting then format with grouping separator', 0, () => {
      fmt('9223372036854775807', '9,223,372,036,854,775,807');
    });
    it('given an already formatted number when formatting then keep the same format', 0, () => {
      fmt('123,456', '123,456');
    });
    it('given a number with leading zeros when formatting then keep the leading zeros for decimal', 0, () => {
      fmt('00100', '00,100');
    });
    it('given a number with leading zeros when formatting then keep the leading zeros for floating-point', 0, () => {
      fmt('0000.0100', '0,000.0100');
    });
    it('given a negative integer number when formatting then format with grouping separator and negative sign', 0, () => {
      fmt('-12345', '-12,345');
    });
    it('given a negative floating-point number when formatting then format with grouping separator, decimal separator, and negative sign', 0, () => {
      fmt('-1234.567', '-1,234.567');
    });
    it('given an empty input when formatting then return empty string', 0, () => {
      fmt('', '');
    });
    it('given a zero input when formatting then return zero', 0, () => {
      fmt('0', '0');
    });
    it('given a zero input with decimal separator when formatting then return zero with decimal separator', 0, () => {
      fmt('0.0', '0.0');
    });
    it('given a floating point number then formatting in Indian Numbering System', 0, () => {
      fmt('1234567.890', '12,34,567.890', 1);
    });
    it('given a large integer number then formatting in Indian Numbering System', 0, () => {
      fmt('987654321', '98,76,54,321', 1);
    });
    it('given a number with two-digit integer part then no formatting is applied', 0, () => {
      fmt('12.34', '12.34', 1);
    });
    it('given a number with exactly three digits then no comma is added', 0, () => {
      fmt('999', '999', 1);
    });
    it('given a number with four digits then a comma is added correctly', 0, () => {
      fmt('1234', '1,234', 1);
    });
    it('given a number with five digits then a comma is added correctly', 0, () => {
      fmt('12345', '12,345', 1);
    });
    it('given a number with six digits then commas are added correctly', 0, () => {
      fmt('123456', '1,23,456', 1);
    });
    it('given a number with decimals then only integer part is formatted', 0, () => {
      fmt('9020555.555', '90,20,555.555', 1);
    });
    it('given a small number then no formatting is applied', 0, () => {
      fmt('5', '5', 1);
    });
    it('given a negative number then formatting is applied correctly', 0, () => {
      fmt('-1234567', '-12,34,567', 1);
    });
  });
}
