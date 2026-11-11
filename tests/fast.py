#!/usr/bin/env python3
"""Compare fast and reference execution, including complete RAM/CPU snapshots."""
from pathlib import Path
import subprocess
import unittest

from cpu import run, end, NTV
from interp import random_program

ROOT = Path(__file__).resolve().parents[1]


class Fast(unittest.TestCase):
    def compare(self, source, options=(), limit=100_000):
        fast = run(source, options=options, limit=limit)
        reference = run(source, options=('--reference', *options), limit=limit)
        self.assertEqual(fast, reference)
        return fast

    def test_seeded_programs(self):
        for seed in range(32):
            with self.subTest(seed=seed):
                self.compare(random_program(4004+seed,'4004'),options=('-o',))

    def test_page_and_cycle_boundaries(self):
        cases = [(0xfe,0x14,2), (0xff,0x30,0), (0xff,0x31,0),
                 (0x1fe,0x7f,1), (0xfff,0x14,2), (0xfff,0x30,0)]
        cases += [(p,0x40+(p>>8),p&255) for p in (0,0xff,0xfff)]
        for address,opcode,operand in cases:
            source = (f'        ORG 800H\n        FIM 0,12H\n        LDM 0\n        CLC\n'
                      f'        JUN {address}\n        ORG {address}\n        DB {opcode}\n'
                      f'        ORG {(address+1)&4095}\n        DB {operand}\n'
                      f'        ORG {(address+2)&4095}\n        JUN HALT\n'
                      '        ORG 900H\nHALT:   JUN HALT\n')
            for budget in (1,2,3,7,31,128):
                with self.subTest(address=address,opcode=opcode,budget=budget):
                    self.compare(source,options=('-a:2048',),limit=budget)

    def test_nop_row_and_stack_wrap(self):
        state,_,code = self.compare('        LDM 7\n        STC\n        DB '+
                                   ','.join(str(i) for i in range(16))+'\n'+end())
        self.assertEqual((state['acc'],state['carry'],state['cycles'],code),(7,1,18,0))
        source = ('        JMS A\n'+end()+'A:      JMS B\n        BBL 1\n'
                  'B:      JMS C\n        BBL 2\nC:      JMS D\n        BBL 3\n'
                  'D:      JMS E\n        BBL 4\nE:      BBL 5\n')
        self.compare(source,limit=512)

    def test_basic_snapshots(self):
        for name,profile in (('e','basic'),('sieve','basic'),('ttt','large')):
            for budget in (65535,65536,65537,2_000_000):
                args = ['-r',f'-n:{budget}','-l:'+str(ROOT/f'basic/examples/{name}.bas'),
                        str(ROOT/f'basic/{profile}.hex')]
                with self.subTest(name=name,budget=budget):
                    results = []
                    for options in ([],['--reference']):
                        p = subprocess.run([str(NTV),*options,*args],capture_output=True,timeout=30)
                        self.assertEqual(p.returncode,2,p.stderr)
                        results.append((p.returncode,p.stdout,p.stderr))
                    self.assertEqual(*results)


if __name__ == '__main__':
    unittest.main()
