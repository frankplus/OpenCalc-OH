import { Space } from '../../theme/Theme';
import { CalcKey } from './CalcKey';

// The keypad: the flat first row, the two scientific rows when shown, then 5 rows of 4 round keys.
// keyH is the height of a main key, computed by the page from the room it has.
@ComponentV2
export struct Keypad {
  @Param sci: boolean = false;
  @Param inv: boolean = false;
  @Param rad: boolean = false;
  @Param split: boolean = false;
  @Param modulo: boolean = true;
  @Param keyH: number = 64;
  @Param flatH: number = 48;
  @Event onKey: (id: string) => void = () => {};
  @Event onInsert: (value: string) => void = () => {};
  @Event onClearAll: () => void = () => {};

  private squareLabel(): string {
    if (!this.inv) {
      return '√';
    }
    return this.modulo ? '#' : 'x²';
  }

  build() {
    Column() {
      Row() {
        CalcKey({ label: this.squareLabel(), eid: 'squareButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('squareButton'); } })
        CalcKey({ label: 'π', eid: 'piButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('piButton'); } })
        CalcKey({ label: '^', eid: 'exponentButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('exponentButton'); } })
        CalcKey({ label: '!', eid: 'factorialButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('factorialButton'); } })
        CalcKey({
          symbol: this.sci ? $r('sys.symbol.chevron_up') : $r('sys.symbol.chevron_down'), eid: 'scientistModeSwitchButton',
          label: $r('app.string.calculator_scientific'), kind: 1, keyHeight: this.flatH,
          onTap: () => { this.onKey('scientistModeSwitchButton'); }
        })
      }
      if (this.sci) {
        Row() {
          CalcKey({ label: this.rad ? 'DEG' : 'RAD', eid: 'degreeButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('degreeButton'); } })
          CalcKey({ label: this.inv ? 'sin⁻¹' : 'sin', eid: 'sineButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('sineButton'); } })
          CalcKey({ label: this.inv ? 'cos⁻¹' : 'cos', eid: 'cosineButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('cosineButton'); } })
          CalcKey({ label: this.inv ? 'tan⁻¹' : 'tan', eid: 'tangentButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('tangentButton'); } })
        }
        Row() {
          CalcKey({ label: $r('app.string.calculator_inv'), eid: 'invButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('invButton'); } })
          CalcKey({ label: 'e', eid: 'eButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('eButton'); } })
          CalcKey({ label: this.inv ? 'e^' : 'ln', eid: 'naturalLogarithmButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('naturalLogarithmButton'); } })
          CalcKey({ label: this.inv ? '10^' : 'log', eid: 'logarithmButton', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('logarithmButton'); } })
          CalcKey({ label: this.inv ? '2^' : 'log₂', eid: 'log2Button', kind: 4, keyHeight: this.flatH, onTap: () => { this.onKey('log2Button'); } })
        }
      }
      Row() {
        if (this.split) {
          CalcKey({ label: '(', eid: 'leftParenthesisButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('leftParenthesisButton'); } })
          CalcKey({ label: ')', eid: 'rightParenthesisButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('rightParenthesisButton'); } })
        } else {
          CalcKey({ label: $r('app.string.calculator_ac'), eid: 'clearButton', kind: 2, keyHeight: this.keyH, onTap: () => { this.onKey('clearButton'); } })
          CalcKey({ label: '( )', eid: 'parenthesesButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('parenthesesButton'); } })
        }
        CalcKey({ label: '%', eid: 'divideBy100Button', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('divideBy100Button'); } })
        CalcKey({ label: '÷', eid: 'divideButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('divideButton'); } })
      }
      Row() {
        CalcKey({ label: '7', eid: 'sevenButton', keyHeight: this.keyH, onTap: () => { this.onKey('sevenButton'); } })
        CalcKey({ label: '8', eid: 'eightButton', keyHeight: this.keyH, onTap: () => { this.onKey('eightButton'); } })
        CalcKey({ label: '9', eid: 'nineButton', keyHeight: this.keyH, onTap: () => { this.onKey('nineButton'); } })
        CalcKey({ label: '×', eid: 'multiplyButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('multiplyButton'); } })
      }
      Row() {
        CalcKey({ label: '4', eid: 'fourButton', keyHeight: this.keyH, onTap: () => { this.onKey('fourButton'); } })
        CalcKey({ label: '5', eid: 'fiveButton', keyHeight: this.keyH, onTap: () => { this.onKey('fiveButton'); } })
        CalcKey({ label: '6', eid: 'sixButton', keyHeight: this.keyH, onTap: () => { this.onKey('sixButton'); } })
        CalcKey({ label: '−', eid: 'subtractButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('subtractButton'); } })
      }
      Row() {
        CalcKey({ label: '1', eid: 'oneButton', keyHeight: this.keyH, onTap: () => { this.onKey('oneButton'); } })
        CalcKey({ label: '2', eid: 'twoButton', keyHeight: this.keyH, onTap: () => { this.onKey('twoButton'); } })
        CalcKey({ label: '3', eid: 'threeButton', keyHeight: this.keyH, onTap: () => { this.onKey('threeButton'); } })
        CalcKey({ label: '+', eid: 'addButton', kind: 1, keyHeight: this.keyH, onTap: () => { this.onKey('addButton'); } })
      }
      Row() {
        CalcKey({
          label: '0', eid: 'zeroButton', zeroMenu: true, keyHeight: this.keyH,
          onTap: () => { this.onKey('zeroButton'); },
          onInsert: (v: string) => { this.onInsert(v); }
        })
        CalcKey({ label: $r('app.string.calculator_point'), dot: true, eid: 'pointButton', keyHeight: this.keyH, onTap: () => { this.onKey('pointButton'); } })
        CalcKey({
          label: '⌫', eid: 'backspaceButton', keyHeight: this.keyH,
          onTap: () => { this.onKey('backspaceButton'); },
          onLong: () => { this.onClearAll(); }
        })
        CalcKey({ label: '=', eid: 'equalsButton', kind: 3, keyHeight: this.keyH, onTap: () => { this.onKey('equalsButton'); } })
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: Space.s, right: Space.s, top: Space.s, bottom: Space.s })
    .justifyContent(FlexAlign.Start)
  }
}
