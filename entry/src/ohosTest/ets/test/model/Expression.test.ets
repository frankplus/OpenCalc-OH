import { describe, expect, it } from '@ohos/hypium';
import { CalculatorStore } from '../../../../main/ets/model/CalculatorStore';

const store: CalculatorStore = CalculatorStore.getInstance();

function eq(input: string, deg: boolean, expected: number): void {
  expect(store.rawValue(input, deg)).assertEqual(expected);
}

function near(input: string, deg: boolean, expected: number, delta: number): void {
  expect(store.rawValue(input, deg)).assertClose(expected, delta);
}

export default function expressionTest() {
  describe('ExpressionUnitTest', () => {
    it('percentage_isCorrect', 0, () => {
      eq('100*95%', false, 95.0);
      eq('(10*10)*95%', false, 95.0);
      eq('100*100%', false, 100.0);
      eq('100*100/100*100%', false, 100.0);
      eq('100%10', false, 10.0);
      eq('10%10%', false, 0.01);
      eq('900/10%', false, 9000.0);
      eq('(5+4)%', false, 0.09);
      eq('5+4%', false, 5.2);
      eq('(50+2)+3%', false, 53.56);
      eq('52+(1+2)%', false, 53.56);
      eq('(50+2)+(1+2)%', false, 53.56);
      eq('164+(265-20%)', false, 376.0);
      eq('(265-20%)+164', false, 376.0);
      eq('164+(265-20%)%', false, 511.68);
      eq('(164+(265-20%)%)+345%', false, 2276.976);
      eq('164%+(265-20%)%+345%', false, 18.75176);
    });
    it('addition_isCorrect', 0, () => {
      eq('1+1', false, 2.0);
      eq('(1+1)+1', false, 3.0);
    });
    it('nested_factorial_isCorrect', 0, () => {
      eq('(3!)!', false, 720.0);
      eq('(2!)!', false, 2.0);
      eq('(1!)!', false, 1.0);
    });
    it('number_factorial_equal_decimal_factorial', 0, () => {
      eq('59!', false, store.rawValue('59.0!', false));
      eq('100!', false, store.rawValue('100.0!', false));
      eq('3004!', false, store.rawValue('3004.0!', false));
    });
    it('decimal_factorial_shows_correct_result', 0, () => {
      near('5.003!', false, 120.6158752971739, 0.000000001);
      near('3.01!', false, 6.075928540616668, 0.000000001);
      near('7.08!', false, 5924.414931297129, 0.000000001);
    });
    it('pow_isCorrect', 0, () => {
      eq('4^3', false, 64.0);
      eq('5^-5', false, 0.00032);
      near('2^3.5', false, 11.31370849898476, 0.0000001);
      near('2^-3.5', false, 0.08838834764, 0.0000001);
      eq('0^2', false, 0.0);
      eq('2^(2+1)', true, 8.0);
    });
    it('subtraction_isCorrect', 0, () => {
      eq('1-1', false, 0.0);
      eq('1-1-1', false, -1.0);
    });
    it('division_isCorrect', 0, () => {
      eq('0.5/0.01', false, 50.0);
      eq('7/2', false, 3.5);
    });
    it('factorial_isCorrect', 0, () => {
      eq('0!', false, 1.0);
      eq('5!', false, 120.0);
      eq('10!', false, 3628800.0);
      eq('5!+5!', false, 240.0);
      eq('(3!)!+(3!)!', false, 1440.0);
      eq('(3!)!/(3!)!', false, 1.0);
    });
    it('factorial_percent_isCorrect', 0, () => {
      eq('5!%', false, 1.2);
      eq('(5!%)+(5!%)', false, 2.4);
      eq('5!%+5!%', false, 2.64);
    });
    it('sqrt_isCorrect', 0, () => {
      eq('√2^2', false, 2.0);
      eq('√9', false, 3.0);
      eq('√0.00', false, 0.0);
      eq('√0.0', false, 0.0);
    });
    it('trigonometric_functions_isCorrect', 0, () => {
      eq('cos(0)', false, 1.0);
      eq('1*cos(0)', false, 1.0);
      eq('1+cos(0)', false, 2.0);
      eq('1-cos(0)', false, 0.0);
      eq('2^cos(0)', false, 2.0);
      eq('(cos(0))', false, 1.0);
      eq('cos(2)', false, -0.4161468365471424);
      eq('tan(π/2)', false, 0.0);
      eq('tan(45)', true, 0.9999999999999999);
      eq('sin(220)', true, -0.6427876096865393);
      eq('sin(5!)', true, 0.8660254037844387);
      eq('sin(1+1)', true, 0.03489949670250097);
      eq('1^(1/sin(2π))', true, 1.0);
      eq('1^(1/sin(2π))', false, 1.0);
    });
    it('log2_isCorrect', 0, () => {
      eq('log₂(8)', false, 3.0);
      eq('log₂(5)+5*log(5)', false, 5.816778116567456);
    });
    it('factorial_square_isCorrect', 0, () => {
      eq('(√16)!', false, 24.0);
      eq('(√16)!+(√16)!', false, 48.0);
      eq('(√16)!+(√16)!+(√16)!', false, 72.0);
    });
    it('evaluate_formats_the_spec_examples', 0, () => {
      expect(store.evaluate('12+7', true, 10, false, 0).value).assertEqual('19');
      expect(store.evaluate('7÷3', true, 10, false, 0).value).assertEqual('2.3333333333');
      expect(store.evaluate('1234×5', true, 10, false, 0).value).assertEqual('6,170');
      expect(store.evaluate('2^10', true, 10, false, 0).value).assertEqual('1,024');
      expect(store.evaluate('√π!', true, 10, false, 0).value).assertEqual('2.681060001');
      expect(store.evaluate('sin(30', true, 10, false, 0).value).assertEqual('0.5');
      expect(store.evaluate('sin(30', false, 10, false, 0).value).assertEqual('-0.9880316241');
      expect(store.evaluate('10#3', true, 10, false, 0).value).assertEqual('1');
      expect(store.evaluate('12345', true, 10, true, 0).value).assertEqual('1.235E+4');
      expect(store.evaluate('1234567', true, 10, false, 1).value).assertEqual('12,34,567');
    });
    it('evaluate_reports_errors', 0, () => {
      expect(store.evaluate('1÷0', true, 10, false, 0).error).assertEqual('division_by_0');
      expect(store.evaluate('', true, 10, false, 0).error).assertEqual('syntax_error');
      expect(store.evaluate('12+', true, 10, false, 0).ok).assertFalse();
      expect(store.evaluate('1)', true, 10, false, 0).error).assertEqual('syntax_error');
      expect(store.evaluate('ln(0)', true, 10, false, 0).error).assertEqual('domain_error');
      expect(store.evaluate('(-5)^0.5', true, 10, false, 0).error).assertEqual('require_real_number');
      expect(store.evaluate('3004!', true, 10, false, 0).error).assertEqual('infinity');
    });
    it('input_editing_rules', 0, () => {
      expect(store.insertValue('123', 3, '4', 0).text).assertEqual('1,234');
      expect(store.addSymbol('5+', 2, '×', 0).text).assertEqual('5×');
      expect(store.addSymbol('', 0, '+', 0).text).assertEqual('');
      expect(store.addSymbol('', 0, '-', 0).text).assertEqual('-');
      expect(store.addPoint('1.5', 3, 0).text).assertEqual('1.5');
      expect(store.addParentheses('', 0, 0).text).assertEqual('(');
      expect(store.addParentheses('(2+3', 4, 0).text).assertEqual('(2+3)');
      expect(store.backspace('123', 3, 0).text).assertEqual('12');
      expect(store.backspace('sin(', 4, 0).text).assertEqual('');
      expect(store.backspace('12', 0, 0).text).assertEqual('12');
    });
  });
}
