#!/usr/bin/python
'''
It's nice sometimes to be able to ask WolframAlpha

"G * (1 solar mass)**2 / (1AU)"

Sometimes it fails to parse, and it requires being online, and is slow. I want
to write a quick script to evaluate such expressions, maybe with some support
for "!!" (previous result) and "!-N" (N results ago) syntaxes.

TODO:
- write out to a log file (datetime, query, result)
- mode to read previous results
'''

UNIT_NAMES = ['kg', 'm', 's']
class Quant(object):
    '''
    units = (mass, length, time) powers (kg, m, s)
    '''
    def __init__(self, val, units):
        super(Quant, self).__init__()
        self.val = val
        self.units = units
    def __str__(self):
        ret = '%s ' % self.val
        for u, name in zip(self.units, UNIT_NAMES):
            if u == 1:
                ret += '%s.' % name
            elif u > 1:
                ret += '%s^%.3f.' % (name, u)
        ret = ret.strip('.')
        ret += '/'
        for u, name in zip(self.units, UNIT_NAMES):
            if u == -1:
                ret += '%s.' % name
            elif u < -1:
                ret += '%s^%.3f.' % (name, -u)
        return ret.strip('./')

    def __add__(self, q1):
        for u1, u2 in zip(self.units, q1.units):
            if u1 != u2:
                raise ValueError('Incompatible units: [%s, %s]' % (self, q1))
        return Quant(self.val + q1.val, self.units)
    def __sub__(self, q1):
        for u1, u2 in zip(self.units, q1.units):
            if u1 != u2:
                raise ValueError('Incompatible units: [%s, %s]' % (self, q1))
        return Quant(self.val - q1.val, self.units)
    def __mul__(self, q1):
        return Quant(self.val * q1.val,
                     [u1 + u2 for u1, u2 in zip(self.units, q1.units)])
    def __truediv__(self, q1):
        return Quant(self.val / q1.val,
                     [u1 - u2 for u1, u2 in zip(self.units, q1.units)])
    def __pow__(self, n):
        if n.units != [0, 0, 0]:
            raise ValueError('Power with units: (`%s` ^ `%s`)' % (self, n))
        return Quant(self.val**n.val, [u1 * n.val for u1 in self.units])
# map of supported units -> (val, (units))
UNITS_DICT = {
    'kg': (1, [1, 0, 0]),
    'm': (1, [0, 1, 0]),
    's': (1, [0, 0, 1]),

    'Msun': (1.99e30, [1, 0, 0]),
}

# generate a Quant from a str
def from_str(expr):
    expr_split = expr.split(' ')
    if len(expr_split) == 1:
        return Quant(float(expr), [0, 0, 0])
    elif len(expr_split) != 2:
        raise ValueError('Malformated Quant: `%s`' % expr)

    _quant_val, units = expr_split
    quant_val = float(_quant_val)
    quant_units = [0, 0, 0]
    def add_unit(new_units, mult):
        for i, u in enumerate(new_units):
            quant_units[i] += mult * u

    unit_split = units.split('/')
    if len(unit_split) == 1:
        units_top = unit_split[0]
        units_bot = None
    elif len(unit_split) == 2:
        units_top, units_bot = unit_split
    else:
        raise ValueError('Malformed units: `%s`' % units)

    for unit_group, sign in [(units_top, 1), (units_bot, -1)]:
        if unit_group is None:
            continue

        for u in unit_group.split('.'):
            components = u.split('^')
            if len(components) == 1:
                unit = components[0]
                power = 1
            elif len(components) == 2:
                unit = components[0]
                power = float(components[1])
            else:
                raise ValueError('Unparseable unit: `%s`' % u)

            if unit not in UNITS_DICT:
                raise ValueError('Unknown unit: `%s`' % u)
            val, new_units = UNITS_DICT[unit]
            quant_val *= val**(sign * power)
            add_unit(new_units, sign * power)
    return Quant(quant_val, quant_units)

def split_with_parens(instr, base_seps, lparen='(', rparen=')', space=' '):
    seps = list(base_seps) + [space]
    words = []
    ops = []
    prev_idx = 0
    idx = 0
    curr_op = None
    while idx < len(instr):
        c = instr[idx]
        # paren handling
        if c == lparen:
            lcount = 1
            rcount = 0
            idx += 1
            prev_idx = idx
            while rcount < lcount:
                if idx >= len(instr):
                    raise ValueError('Mismatched parens: `%s`' % instr)
                c = instr[idx]
                if c == lparen:
                    lcount += 1
                elif c == rparen:
                    rcount += 1
                idx += 1
            if len(words) and curr_op is None:
                raise ValueError('Missing op: `%s`' % instr)
            if curr_op is not None:
                ops.append(curr_op)
                curr_op = None
            words.append(instr[prev_idx:idx - 1])
            prev_idx = idx + 1
        # if is not an operator/space
        if c not in seps:
            idx += 1
            continue

        # update curr_op if exists
        if c != ' ':
            if curr_op is None:
                curr_op = c
            else:
                raise ValueError('Consecutive operators: `%s`' % instr)

        # if is operator, append if not empty expr
        if idx - prev_idx > 0:
            if len(words) and curr_op is None:
                raise ValueError('Missing op: `%s`' % instr)
            if curr_op is not None:
                ops.append(curr_op)
                curr_op = None
            words.append(instr[prev_idx:idx])
        prev_idx = idx + 1
        idx += 1
    idx = len(instr)
    if idx - prev_idx > 0:
        words.append(instr[prev_idx:idx])
    if curr_op is not None:
        ops.append(curr_op)
    return words, ops

operators = {
    '+': lambda x, y: x + y,
    '-': lambda x, y: x - y,
    '*': lambda x, y: x * y,
    '/': lambda x, y: x - y,
    '^': lambda x, y: x ** y,
}
first_operators = ['^', '/', '*']
def eval_expr(expr):
    pieces, ops = split_with_parens(expr, operators.keys())
    # base case
    if len(ops) == 0:
        return from_str(expr)

    # recursive case, use order of operations by doing 2 passes
    pieces_eval = [eval_expr(p) for p in pieces]

    pieces2 = []
    ops2 = []
    curr_res = pieces_eval[0]
    for idx, op in enumerate(ops):
        if op not in first_operators:
            ops2.append(op)
            pieces2.append(curr_res)
            curr_res = pieces_eval[idx + 1]
        else:
            curr_res = operators[op](curr_res, pieces_eval[idx + 1])
    pieces2.append(curr_res)

    # second pass, just operate in order
    curr_res = pieces2[0]
    for idx, op in enumerate(ops2):
        curr_res = operators[op](curr_res, pieces2[idx + 1])
    return curr_res

if __name__ == '__main__':
    print(eval_expr('5 ^ 2 + 3'))
    print(eval_expr('5 * (1 Msun)'))
