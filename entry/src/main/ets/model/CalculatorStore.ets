// The data layer's contract, from the AppSpec: The calculation engine ported from Calculator.kt, Expression.kt and NumberFormatter.kt plus the input-editing rules of MainActivity; pure functions, nothing persisted.
import { common } from '@kit.AbilityKit';
import { CalcResult } from './CalcResult';
import { InputEdit } from './InputEdit';
import { CalcFlags, Evaluator, Expression, formatNumbers, roundedText, trimNumberText } from './CalcEngine';

const SYMBOL_SET: string = '+\\-÷×';

function edit(text: string, caret: number): InputEdit {
  const e = new InputEdit();
  e.text = text;
  e.caret = caret;
  return e;
}

function failed(error: string, value: string = ''): CalcResult {
  const r = new CalcResult();
  r.ok = false;
  r.value = value;
  r.error = error;
  return r;
}

/** Java's %.4g: 4 significant digits, half-up, E notation outside 1e-4 <= x < 1e4. */
function formatG4(v: number): string {
  const sign = v < 0 ? '-' : '';
  const abs = Math.abs(v);
  let exp = Math.floor(Math.log10(abs));
  const scaled = (e: number): number => (e >= 3 ? Math.round(abs / Math.pow(10, e - 3)) : Math.round(abs * Math.pow(10, 3 - e)));
  let m = scaled(exp);
  if (m >= 10000) {
    exp += 1;
    m = scaled(exp);
  } else if (m < 1000) {
    exp -= 1;
    m = scaled(exp);
  }
  const digits = m.toString();
  if (exp >= 4 || exp < -4) {
    return sign + digits[0] + '.' + digits.substring(1) + 'E' + (exp >= 0 ? '+' : '-') + Math.abs(exp);
  }
  if (exp >= 3) {
    return sign + digits;
  }
  if (exp >= 0) {
    return sign + digits.substring(0, exp + 1) + '.' + digits.substring(exp + 1);
  }
  return sign + '0.' + '0'.repeat(-exp - 1) + digits;
}

export class CalculatorStore {
  private static instance: CalculatorStore | null = null;

  static getInstance(): CalculatorStore {
    if (CalculatorStore.instance === null) {
      CalculatorStore.instance = new CalculatorStore();
    }
    return CalculatorStore.instance;
  }

  /** Nothing is persisted: the engine is pure. */
  async init(context: common.Context): Promise<void> {
  }

  /** The raw double the expression evaluates to (flags ignored); used by the unit tests of the original. */
  rawValue(input: string, degreeMode: boolean): number {
    const flags = new CalcFlags();
    const clean = new Expression(flags).getCleanExpression(input, '.', ',');
    return new Evaluator(flags, 10).evaluate(clean, degreeMode);
  }

  evaluate(input: string, degreeMode: boolean, precision: number, scientificNotation: boolean, numberingSystem: number): CalcResult {
    if (input.length === 0) {
      return failed('syntax_error');
    }
    const flags = new CalcFlags();
    const clean = new Expression(flags).getCleanExpression(input, '.', ',');
    const v = new Evaluator(flags, precision).evaluate(clean, degreeMode);
    if (flags.divisionBy0) {
      return failed('division_by_0');
    }
    if (flags.domainError) {
      return failed('domain_error');
    }
    if (flags.syntaxError) {
      return failed('syntax_error');
    }
    if (flags.requireRealNumber) {
      return failed('require_real_number');
    }
    if (flags.isInfinity) {
      return failed('infinity');
    }
    if (isNaN(v)) {
      return failed('domain_error');
    }
    if (!isFinite(v)) {
      return failed('infinity', v < 0 ? '-' : '');
    }
    const result = new CalcResult();
    result.ok = true;
    const rv = Number(roundedText(v, precision));
    const abs = Math.abs(rv);
    if (scientificNotation && rv !== 0 && (abs >= 9999 || abs <= 0.1)) {
      result.value = formatG4(rv);
      return result;
    }
    const text = trimNumberText(roundedText(v, precision));
    result.value = formatNumbers(text, numberingSystem);
    return result;
  }

  errorMessage(result: CalcResult): Resource {
    switch (result.error) {
      case 'division_by_0':
        return $r('app.string.CalculatorStore_division_by_0');
      case 'domain_error':
        return $r('app.string.CalculatorStore_domain_error');
      case 'require_real_number':
        return $r('app.string.CalculatorStore_require_real_number');
      case 'infinity':
        return result.value === '-' ? $r('app.string.CalculatorStore_neg_infinity') :
          $r('app.string.CalculatorStore_infinity');
      default:
        return $r('app.string.CalculatorStore_syntax_error');
    }
  }

  isErrorColoured(result: CalcResult): boolean {
    return !result.ok && (result.error === 'division_by_0' || result.error === 'domain_error' ||
      result.error === 'syntax_error' || result.error === 'require_real_number');
  }

  formatInput(text: string, numberingSystem: number): string {
    return formatNumbers(text, numberingSystem);
  }

  insertValue(text: string, caret: number, value: string, numberingSystem: number): InputEdit {
    const c = Math.max(0, Math.min(caret, text.length));
    const left = text.substring(0, c);
    const right = text.substring(c);
    const formattedLeft = formatNumbers(left + value, numberingSystem);
    const full = formatNumbers(left + value + right, numberingSystem);
    return edit(full, Math.min(formattedLeft.length, full.length));
  }

  addSymbol(text: string, caret: number, symbol: string, numberingSystem: number): InputEdit {
    const len = text.length;
    const unchanged = edit(text, caret);
    if (len === 0) {
      return symbol === '-' ? this.insertValue(text, caret, symbol, numberingSystem) : unchanged;
    }
    const cp = Math.max(0, Math.min(caret, len));
    const nextChar = len - cp > 0 ? text.charAt(cp) : '0';
    const prevChar = cp > 0 ? text.charAt(cp - 1) : '0';
    const prevSymbol = cp > 1 ? text.charAt(cp - 2) : '0';
    const allowed = symbol !== prevChar && symbol !== nextChar && prevChar !== '√' && prevChar !== '.' &&
      (prevChar !== '(' || symbol === '-') &&
      (SYMBOL_SET.indexOf(prevSymbol) < 0 || SYMBOL_SET.indexOf(prevChar) < 0);
    if (!allowed) {
      return unchanged;
    }
    if ('+-÷×^'.indexOf(prevChar) >= 0) {
      const leftString = text.substring(0, cp - 1);
      const rightString = text.substring(cp);
      if (symbol === '-') {
        if ('+-'.indexOf(prevChar) >= 0) {
          return edit(leftString + symbol + rightString, cp);
        }
        return edit(leftString + prevChar + symbol + rightString, cp + 1);
      } else if (cp > 1 && text.charAt(cp - 2) !== '(') {
        return edit(leftString + symbol + rightString, cp);
      } else if (symbol === '+') {
        return edit(leftString + rightString, cp - 1);
      }
      return unchanged;
    }
    if ('+-÷×^%!'.indexOf(nextChar) >= 0 && symbol !== '%') {
      const leftString = text.substring(0, cp);
      const rightString = text.substring(cp + 1);
      if (cp > 0 && prevChar !== '(') {
        return edit(leftString + symbol + rightString, cp + 1);
      } else if (symbol === '+') {
        return edit(leftString + rightString, cp);
      }
      return unchanged;
    }
    if (cp > 0 || (nextChar !== '0' && symbol === '-')) {
      return this.insertValue(text, cp, symbol, numberingSystem);
    }
    return unchanged;
  }

  addPoint(text: string, caret: number, numberingSystem: number): InputEdit {
    const cp = Math.max(0, Math.min(caret, text.length));
    let current = '';
    if (text.length > 0) {
      let start = 0;
      let end = 0;
      const isPart = (c: string): boolean => (c >= '0' && c <= '9') || c === '.' || c === ',';
      if (cp > 0) {
        start = cp;
        while (start > 0 && isPart(text.charAt(start - 1))) {
          start -= 1;
        }
      }
      if (cp === text.length) {
        end = text.length;
      }
      if (cp < text.length) {
        end = cp;
        while (end < text.length && isPart(text.charAt(end))) {
          end += 1;
        }
      }
      current = text.substring(start, end);
    }
    if (current.indexOf('.') < 0) {
      return this.insertValue(text, cp, '.', numberingSystem);
    }
    return edit(text, cp);
  }

  addParentheses(text: string, caret: number, numberingSystem: number): InputEdit {
    const cp = Math.max(0, Math.min(caret, text.length));
    let open = 0;
    let close = 0;
    for (let i = 0; i < cp; i++) {
      if (text.charAt(i) === '(') {
        open += 1;
      }
      if (text.charAt(i) === ')') {
        close += 1;
      }
    }
    const nextIsOp = text.length > cp && '×÷+-^'.indexOf(text.charAt(cp)) >= 0;
    const prev = cp > 0 ? text.charAt(cp - 1) : '';
    const opens = !nextIsOp && (open === close || prev === '(' || (prev.length > 0 && '×÷+-^'.indexOf(prev) >= 0));
    return this.insertValue(text, cp, opens ? '(' : ')', numberingSystem);
  }

  backspace(text: string, caret: number, numberingSystem: number): InputEdit {
    const cp = Math.max(0, Math.min(caret, text.length));
    if (cp === 0 || text.length === 0) {
      return edit(text, cp);
    }
    const fns: string[] = ['cos⁻¹(', 'sin⁻¹(', 'tan⁻¹(', 'cos(', 'sin(', 'tan(', 'ln(', 'log(', 'log₂(', 'exp('];
    const leftPart = text.substring(0, cp);
    let newLeft = '';
    let found = false;
    for (const fn of fns) {
      if (leftPart.endsWith(fn)) {
        newLeft = leftPart.substring(0, leftPart.length - fn.length);
        found = true;
        break;
      }
    }
    if (!found) {
      newLeft = leftPart.substring(0, leftPart.length - 1);
    }
    const right = text.substring(cp);
    const formattedLeft = formatNumbers(newLeft, numberingSystem);
    const full = formatNumbers(newLeft + right, numberingSystem);
    return edit(full, Math.min(formattedLeft.length, full.length));
  }
}
