// Ported from Calculator.kt, Expression.kt and NumberFormatter.kt (OpenCalc). Arithmetic is done in doubles.

export class CalcFlags {
  divisionBy0: boolean = false;
  domainError: boolean = false;
  syntaxError: boolean = false;
  isInfinity: boolean = false;
  requireRealNumber: boolean = false;
}

function inSet(c: string, set: string): boolean {
  return c.length > 0 && set.indexOf(c) >= 0;
}

function isDigitCh(c: string): boolean {
  return c.length === 1 && c >= '0' && c <= '9';
}

function insertAt(s: string, ch: string, index: number): string {
  return s.substring(0, index) + ch + s.substring(index);
}

function replaceAllStr(s: string, a: string, b: string): string {
  return s.split(a).join(b);
}

function lastIndexOfAny(s: string, chars: string): number {
  for (let i = s.length - 1; i >= 0; i--) {
    if (chars.indexOf(s.charAt(i)) >= 0) {
      return i;
    }
  }
  return -1;
}

function r15(x: number): number {
  if (!isFinite(x) || x === 0) {
    return x;
  }
  return Number(x.toPrecision(15));
}

function isShort(x: number): boolean {
  return r15(x) === x;
}

/** Arithmetic that behaves like decimal arithmetic when both operands are short decimals. */
function tidy(a: number, b: number, r: number): number {
  return (isShort(a) && isShort(b)) ? r15(r) : r;
}

export class Expression {
  private flags: CalcFlags;

  constructor(flags: CalcFlags) {
    this.flags = flags;
  }

  getCleanExpression(calculation: string, decimalSep: string, groupingSep: string): string {
    let c = this.replaceSymbols(calculation, decimalSep, groupingSep);
    c = this.addMultiply(c);
    if (c.indexOf('√') >= 0) {
      c = this.formatSquare(c);
    }
    if (c.indexOf('%') >= 0) {
      c = this.getPercentString(c);
      c = replaceAllStr(c, '%', '/100');
    }
    if (c.indexOf('!') >= 0) {
      c = this.formatFactorial(c);
    }
    c = this.addParenthesis(c);
    return c;
  }

  private replaceSymbols(calculation: string, decimalSep: string, groupingSep: string): string {
    let c = replaceAllStr(calculation, '×', '*');
    c = replaceAllStr(c, '÷', '/');
    c = replaceAllStr(c, 'log₂(', 'logtwo(');
    c = replaceAllStr(c, 'log(', 'logten(');
    c = replaceAllStr(c, 'E', '*10^');
    c = replaceAllStr(c, 'exp', 'xp');
    c = replaceAllStr(c, 'cos⁻¹', 'arcco');
    c = replaceAllStr(c, 'sin⁻¹', 'arcsi');
    c = replaceAllStr(c, 'tan⁻¹', 'arcta');
    c = replaceAllStr(c, groupingSep, '');
    c = replaceAllStr(c, decimalSep, '.');
    return c;
  }

  private getPercentString(calculation: string): string {
    let result = calculation;
    let i = 0;
    let level = 0;
    let subStart = -1;
    const processed: Set<number> = new Set<number>();
    while (i < result.length) {
      const ch = result.charAt(i);
      if (ch === '(') {
        if (level === 0) {
          subStart = i;
        }
        level += 1;
      } else if (ch === ')') {
        level -= 1;
        if (level === 0 && subStart >= 0) {
          const sub = result.substring(subStart + 1, i);
          if (sub.indexOf('%') >= 0) {
            const ps = this.getPercentString(sub);
            result = result.substring(0, subStart + 1) + ps + result.substring(i);
            i = 0;
            processed.clear();
            level = 0;
            subStart = -1;
            continue;
          }
          subStart = -1;
        } else if (level < 0) {
          this.flags.syntaxError = true;
          return result;
        }
      } else if (ch === '%') {
        if (level === 0 && !processed.has(i)) {
          processed.add(i);
          if (i > 0 && result.charAt(i - 1) === '!') {
            let j = i - 2;
            while (j >= 0 && (isDigitCh(result.charAt(j)) || result.charAt(j) === '.')) {
              j -= 1;
            }
            const base0 = result.substring(j + 1, i - 1);
            if (base0.length === 0) {
              this.flags.syntaxError = true;
              return result;
            }
            const opPos = lastIndexOfAny(result.substring(0, j + 1), '+-*/');
            if (opPos < 0) {
              result = result.substring(0, j + 1) + '((' + base0 + '!)/100)' + result.substring(i + 1);
            } else if (result.charAt(opPos) === '*' || result.charAt(opPos) === '/') {
              result = result.substring(0, opPos + 1) + '((' + base0 + '!)/100)' + result.substring(i + 1);
            } else {
              const base = result.substring(0, opPos).trim();
              if (base.length === 0) {
                this.flags.syntaxError = true;
                return result;
              }
              result = base + result.charAt(opPos) + base + '*((' + base0 + '!)/100)' + result.substring(i + 1);
            }
          } else if (i > 0 && result.charAt(i - 1) === ')') {
            let j = i - 2;
            let lv = 1;
            while (j >= 0) {
              if (result.charAt(j) === ')') {
                lv += 1;
              } else if (result.charAt(j) === '(') {
                lv -= 1;
              }
              if (lv === 0) {
                break;
              }
              j -= 1;
            }
            if (lv !== 0 || j <= 0) {
              this.flags.syntaxError = true;
              return result;
            }
            const sub = result.substring(j + 1, i - 1);
            const opPos = lastIndexOfAny(result.substring(0, j), '+-*/');
            if (opPos < 0) {
              result = result.substring(0, j) + '((' + sub + ')/100)' + result.substring(i + 1);
            } else if (result.charAt(opPos) === '*' || result.charAt(opPos) === '/') {
              result = result.substring(0, opPos + 1) + '((' + sub + ')/100)' + result.substring(i + 1);
            } else {
              const base = result.substring(0, opPos).trim();
              if (base.length === 0) {
                this.flags.syntaxError = true;
                return result;
              }
              result = base + result.charAt(opPos) + base + '*((' + sub + ')/100)' + result.substring(i + 1);
            }
          } else {
            let start = i - 1;
            while (start >= 0 && (isDigitCh(result.charAt(start)) || result.charAt(start) === '.')) {
              start -= 1;
            }
            const opPos = lastIndexOfAny(result.substring(0, start + 1), '+-*/');
            if (opPos < 0) {
              const num = result.substring(start + 1, i);
              if (num.length === 0) {
                this.flags.syntaxError = true;
                return result;
              }
              result = result.substring(0, start + 1) + '(' + num + '/100)' + result.substring(i + 1);
            } else if (result.charAt(opPos) === '*' || result.charAt(opPos) === '/') {
              const num = result.substring(opPos + 1, i);
              if (num.length === 0) {
                this.flags.syntaxError = true;
                return result;
              }
              result = result.substring(0, opPos + 1) + '(' + num + '/100)' + result.substring(i + 1);
            } else {
              const base = result.substring(0, opPos).trim();
              const num = result.substring(opPos + 1, i);
              if (base.length === 0 || num.length === 0) {
                this.flags.syntaxError = true;
                return result;
              }
              result = base + result.charAt(opPos) + base + '*(' + num + '/100)' + result.substring(i + 1);
            }
          }
          i = 0;
          level = 0;
          subStart = -1;
          continue;
        }
      }
      i += 1;
    }
    if (level !== 0) {
      this.flags.syntaxError = true;
    }
    return result;
  }

  addParenthesis(calculation: string): string {
    let c = calculation;
    let open = 0;
    let close = 0;
    for (let i = 0; i < calculation.length; i++) {
      if (calculation.charAt(i) === '(') {
        open += 1;
      }
      if (calculation.charAt(i) === ')') {
        close += 1;
      }
    }
    if (close < open) {
      for (let i = 0; i < open - close; i++) {
        c += ')';
      }
    }
    if (close > open) {
      this.flags.syntaxError = true;
    }
    return c;
  }

  private addMultiply(calculation: string): string {
    let c = calculation;
    let len = c.length;
    let i = 0;
    while (i < len) {
      const ch = c.charAt(i);
      const next = i + 1 < c.length ? c.charAt(i + 1) : '';
      const prev = i - 1 >= 0 ? c.charAt(i - 1) : '';
      if (ch === '(') {
        if (i !== 0 && inSet(prev, '.e0123456789)')) {
          c = insertAt(c, '*', i);
          len++;
        }
      } else if (ch === ')') {
        if (inSet(next, '0123456789(.')) {
          c = insertAt(c, '*', i + 1);
          len++;
        }
      } else if (ch === '!') {
        if (inSet(next, '0123456789π(')) {
          c = insertAt(c, '*', i + 1);
          len++;
        }
      } else if (ch === '%') {
        if (inSet(next, '0123456789π(')) {
          c = insertAt(c, '*', i + 1);
          len++;
        }
      } else if (i - 1 >= 0 && ch === '√') {
        if (!inSet(prev, '+-/*(')) {
          c = insertAt(c, '*', i);
          len++;
        }
      } else if (ch === 'π') {
        if (inSet(next, '0123456789(')) {
          c = insertAt(c, '*', i + 1);
          len++;
        }
        if (i - 1 >= 0 && inSet(c.charAt(i - 1), '.%πe0123456789)')) {
          c = insertAt(c, '*', i);
          len++;
        }
      } else if (ch === 'e') {
        if (inSet(next, 'π0123456789(')) {
          c = insertAt(c, '*', i + 1);
          len++;
        }
        if (i - 1 >= 0 && inSet(c.charAt(i - 1), '.%πe0123456789)')) {
          c = insertAt(c, '*', i);
          len++;
        }
      } else {
        if (i + 1 < c.length) {
          const fns: string[] = ['arcco', 'arcsi', 'arcta', 'cos', 'sin', 'tan', 'ln', 'log', 'xp'];
          for (const fn of fns) {
            const text = c.substring(0, i + 1);
            if (text.endsWith(fn) && text.length !== fn.length) {
              if (!inSet(text.charAt(text.length - fn.length - 1), '+-/*(^')) {
                c = c.substring(0, i - fn.length + 1) + '*' + fn + c.substring(i + 1);
                len++;
                break;
              }
            }
          }
        }
      }
      i++;
    }
    return c;
  }

  private formatSquare(calculation: string): string {
    let c = calculation;
    let opened = 0;
    let i = 0;
    while (i < c.length) {
      if (i < c.length - 1) {
        if (opened > 0) {
          if (inSet(c.charAt(i + 1), '(*-/+^)')) {
            c = insertAt(c, ')', i + 1);
            opened -= 1;
          }
        }
        if (c.charAt(i) === '√' && c.charAt(i + 1) !== '(') {
          c = insertAt(c, '(', i + 1);
          opened += 1;
        }
      }
      i++;
    }
    return replaceAllStr(c, '√', 'sqrt');
  }

  private formatFactorial(calculation: string): string {
    let i = calculation.length - 1;
    if (i === 0) {
      this.flags.syntaxError = true;
      return '';
    }
    let c = calculation;
    while (i > 0) {
      let opened = 0;
      if (c.charAt(i) === '!') {
        if (c.charAt(i - 1) === ')') {
          c = c.substring(0, i) + c.substring(i + 1);
          let j = i;
          while (j > 0) {
            if (inSet(c.charAt(j - 1), '*/+^') && opened === 0) {
              break;
            }
            if (c.charAt(j - 1) === ')') {
              opened += 1;
            }
            if (c.charAt(j - 1) !== ')') {
              if (c.charAt(j - 1) === '(') {
                opened -= 1;
              }
              if (opened === 0) {
                c = insertAt(c, 'F', j - 1);
                break;
              }
            }
            j--;
          }
        } else {
          c = c.substring(0, i) + ')' + c.substring(i + 1);
          const tmp = i;
          while (i > 0 && !inSet(c.charAt(i - 1), '()*-/+^')) {
            if (c.charAt(i) === ')') {
              opened += 1;
            } else if (c.charAt(i) === '(') {
              opened -= 1;
            }
            while (i > 1 && (isDigitCh(c.charAt(i - 1)) || c.charAt(i - 1) === '.') &&
              !inSet(c.charAt(i - 2), '()*-/+^')) {
              i--;
            }
            if (opened === 1) {
              c = insertAt(c, '(', i - 1);
              c = insertAt(c, 'F', i - 1);
            }
            i--;
          }
          i = tmp;
        }
      }
      i--;
    }
    return replaceAllStr(c, 'F', 'factorial');
  }
}

export class Evaluator {
  private flags: CalcFlags;
  private eq: string = '';
  private pos: number = -1;
  private ch: string = '';
  private degree: boolean = false;
  private precision: number = 10;

  constructor(flags: CalcFlags, precision: number) {
    this.flags = flags;
    this.precision = precision;
  }

  evaluate(equation: string, degree: boolean): number {
    this.eq = equation;
    this.degree = degree;
    this.pos = -1;
    this.nextChar();
    return this.parseExpression();
  }

  private nextChar(): void {
    this.pos++;
    this.ch = this.pos < this.eq.length ? this.eq.charAt(this.pos) : '';
  }

  private eat(c: string): boolean {
    while (this.ch === ' ') {
      this.nextChar();
    }
    if (this.ch === c) {
      this.nextChar();
      return true;
    }
    return false;
  }

  private parseExpression(): number {
    let x = this.parseTerm();
    while (true) {
      if (this.eat('+')) {
        const y = this.parseTerm();
        x = tidy(x, y, x + y);
      } else if (this.eat('-')) {
        const y = this.parseTerm();
        x = tidy(x, y, x - y);
      } else {
        return x;
      }
    }
    return x;
  }

  private parseTerm(): number {
    let x = this.parseFactor();
    while (true) {
      if (this.eat('*')) {
        const y = this.parseFactor();
        x = tidy(x, y, x * y);
      } else if (this.eat('#')) {
        const d = this.parseFactor();
        if (d === 0) {
          this.flags.divisionBy0 = true;
          x = 0;
        } else {
          x = x % d;
        }
      } else if (this.eat('/')) {
        const d = this.parseFactor();
        if (d === 0 || Math.fround(d) === 0 || d === -2.4492935982947064E-16) {
          this.flags.divisionBy0 = true;
          x = 0;
        } else {
          x = tidy(x, d, x / d);
        }
      } else {
        return x;
      }
    }
    return x;
  }

  private isLetter(): boolean {
    return this.ch.length === 1 && this.ch >= 'a' && this.ch <= 'z';
  }

  private isNumChar(): boolean {
    return (this.ch.length === 1 && this.ch >= '0' && this.ch <= '9') || this.ch === '.';
  }

  private parseFactor(): number {
    if (this.eat('+')) {
      return this.parseFactor();
    }
    if (this.eat('-')) {
      return -this.parseFactor();
    }
    let x: number = 0;
    const startPos = this.pos;
    if (this.eat('(')) {
      x = this.parseExpression();
      if (!this.eat(')')) {
        x = 0;
        this.flags.syntaxError = true;
      }
    } else if (this.isNumChar()) {
      while (this.isNumChar()) {
        this.nextChar();
      }
      const s = this.eq.substring(startPos, this.pos);
      if (s.split('.').length - 1 > 1 || s === '.') {
        x = 0;
        this.flags.syntaxError = true;
      } else {
        x = parseFloat(s);
      }
    } else if (this.eat('e')) {
      x = Math.E;
    } else if (this.eat('π')) {
      x = Math.PI;
    } else if (this.isLetter()) {
      while (this.isLetter()) {
        this.nextChar();
      }
      const fn = this.eq.substring(startPos, this.pos);
      if (this.eat('(')) {
        x = this.parseExpression();
        if (!this.eat(')')) {
          x = this.parseFactor();
        }
      } else {
        x = this.parseFactor();
      }
      x = this.applyFunction(fn, x);
    } else {
      x = 0;
      this.flags.syntaxError = true;
    }
    if (this.eat('^')) {
      x = this.exponentiation(x, this.parseFactor());
    }
    return x;
  }

  private tinyFix(x: number): number {
    return (x > 0 && x < 1.0E-14) ? Math.round(x) : x;
  }

  private applyFunction(fn: string, v: number): number {
    let x = v;
    const f = this.flags;
    const big = Number.MAX_VALUE;
    if (fn === 'sqrt') {
      if (x >= 0) {
        x = Math.sqrt(x);
      } else {
        f.requireRealNumber = true;
      }
    } else if (fn === 'factorial') {
      x = this.factorial(x);
    } else if (fn === 'ln' || fn === 'logtwo' || fn === 'logten') {
      if (x > big) {
        f.isInfinity = true;
        x = 0;
      } else if (x <= 0) {
        f.domainError = true;
      } else if (fn === 'ln') {
        x = Math.log(x);
      } else if (fn === 'logtwo') {
        x = Math.log2(x);
      } else {
        x = Math.log10(x);
      }
    } else if (fn === 'xp') {
      x = this.exponentiation(Math.E, x);
    } else if (fn === 'sin' || fn === 'cos') {
      if (x > big) {
        f.isInfinity = true;
        x = 0;
      } else {
        const a = this.degree ? x * Math.PI / 180 : x;
        x = fn === 'sin' ? Math.sin(a) : Math.cos(a);
      }
      x = this.tinyFix(x);
    } else if (fn === 'tan') {
      if (x > big) {
        f.isInfinity = true;
        x = 0;
      } else if (x * 180 / Math.PI === 90.0) {
        f.domainError = true;
        x = 0;
      } else {
        x = Math.tan(this.degree ? x * Math.PI / 180 : x);
        x = this.tinyFix(x);
      }
    } else if (fn === 'arcsi' || fn === 'arcco') {
      if (Math.abs(x) > 1) {
        x = 0;
        f.domainError = true;
      } else {
        const r = fn === 'arcsi' ? Math.asin(x) : Math.acos(x);
        x = this.degree ? r * 180 / Math.PI : r;
        x = this.tinyFix(x);
      }
    } else if (fn === 'arcta') {
      if (x > big) {
        f.isInfinity = true;
        x = 0;
      } else {
        const r = Math.atan(x);
        x = this.degree ? r * 180 / Math.PI : r;
      }
      x = this.tinyFix(x);
    } else {
      f.syntaxError = true;
    }
    return x;
  }

  factorial(n: number): number {
    if (n >= 3000) {
      this.flags.isInfinity = true;
      return 0;
    }
    if (n < 0) {
      this.flags.domainError = true;
      return 0;
    }
    const frac = n - Math.trunc(n);
    if (frac === 0) {
      let r = 1;
      for (let i = 2; i <= n; i++) {
        r *= i;
      }
      return r;
    }
    return this.gamma(n + 1);
  }

  private gamma(x: number): number {
    const p: number[] = [676.5203681218851, -1259.1392167224028, 771.3234287776531, -176.6150291621406,
      12.507343278686905, -0.13857109526572012, 9.984369578019572e-6, 1.5056327351493116e-7];
    const z = x - 1.0;
    let a = 0.9999999999998099;
    for (let i = 0; i < p.length; i++) {
      a += p[i] / (z + i + 1);
    }
    const t = z + 7.0 + 0.5;
    const r = Math.sqrt(2.0 * Math.PI) * Math.pow(t, z + 0.5) * Math.exp(-t) * a;
    return Number(r.toPrecision(16));
  }

  private exponentiation(x: number, factor: number): number {
    let value = x;
    const intPart = Math.trunc(factor);
    const decPart = factor - intPart;
    if (value === 0) {
      return 0;
    }
    if (factor > 10000) {
      this.flags.isInfinity = true;
      return 0;
    }
    if (value < 0 && decPart !== 0) {
      this.flags.requireRealNumber = true;
      return value;
    }
    if (factor > 0) {
      if (decPart === 0) {
        value = r15(Math.pow(value, intPart));
      } else {
        value = Math.pow(value, intPart) * Math.pow(value, decPart);
      }
    } else {
      let d = Math.pow(value, -intPart);
      if (decPart !== 0) {
        d = d * Math.pow(value, -decPart);
      }
      value = 1 / d;
    }
    return value;
  }

  /** Whole-number text of a double, without exponent notation. */
  static plain(v: number): string {
    if (Math.abs(v) >= 1e21) {
      return BigInt(v).toString();
    }
    const s = String(v);
    if (s.indexOf('e') < 0) {
      return s;
    }
    // small numbers such as 1e-7
    return v.toFixed(Math.min(100, 20));
  }
}

export function groupIntegers(integers: string, international: boolean): string {
  if (international) {
    let out = '';
    let count = 0;
    for (let i = integers.length - 1; i >= 0; i--) {
      out = integers.charAt(i) + out;
      count++;
      if (count === 3 && i !== 0) {
        out = ',' + out;
        count = 0;
      }
    }
    return out;
  }
  const negative = integers.startsWith('-');
  const body = negative ? integers.substring(1) : integers;
  const parts = body.split('.');
  const ip = parts[0];
  const dp = parts.length > 1 ? parts[1] : '';
  const length = ip.length;
  let result = '';
  let count = 0;
  for (let i = length - 1; i >= 0; i--) {
    result = ip.charAt(i) + result;
    count++;
    if (count === 3 && i !== 0) {
      result = ',' + result;
      count = 0;
    } else if (count === 2 && i !== 0 && length - i > 3) {
      result = ',' + result;
      count = 0;
    }
  }
  const num = dp.length > 0 ? result + '.' + dp : result;
  return negative ? '-' + num : num;
}

/** NumberFormatter.format with "." and "," separators. */
export function formatNumbers(text: string, numberingSystem: number): string {
  const clean = replaceAllStr(text, ',', '');
  const tokens: string[] = [];
  let cur = '';
  for (let i = 0; i < clean.length; i++) {
    const c = clean.charAt(i);
    if (isDigitCh(c) || c === '.') {
      cur += c;
    } else {
      if (cur.length > 0) {
        tokens.push(cur);
        cur = '';
      }
      tokens.push(c);
    }
  }
  if (cur.length > 0) {
    tokens.push(cur);
  }
  const international = numberingSystem !== 1;
  let out = '';
  for (const t of tokens) {
    if (t.indexOf('.') >= 0) {
      if (t.charAt(0) === '.') {
        out += t;
      } else {
        const dot = t.indexOf('.');
        out += groupIntegers(t.substring(0, dot), international) + '.' + t.substring(dot + 1);
      }
    } else {
      out += groupIntegers(t, international);
    }
  }
  return out;
}

/** Rounds half-even to `precision` decimals and returns plain text (no grouping). */
export function roundedText(v: number, precision: number): string {
  if (precision >= 1000) {
    return Evaluator.plain(v);
  }
  const p = Math.min(precision, 100);
  if (Math.abs(v) >= 1e21) {
    return BigInt(v).toString();
  }
  let x = v;
  if (p <= 15) {
    const scale = Math.pow(10, p);
    const scaled = v * scale;
    if (Math.abs(scaled) < 4503599627370496) {
      const fl = Math.floor(scaled);
      if (scaled - fl === 0.5) {
        const even = fl % 2 === 0 ? fl : fl + 1;
        x = even / scale;
      }
    }
  }
  return x.toFixed(p);
}

export function trimNumberText(s: string): string {
  let t = s;
  if (t.indexOf('.') >= 0) {
    while (t.endsWith('0')) {
      t = t.substring(0, t.length - 1);
    }
    if (t.endsWith('.')) {
      t = t.substring(0, t.length - 1);
    }
  }
  if (t === '-0' || t === '' || t === '-') {
    return '0';
  }
  return t;
}
