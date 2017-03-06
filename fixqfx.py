#!/usr/bin/env python
# encoding: utf-8
'''
fixqfx -- fix Chase QFX files for gnucash

fixqfx is a description

It defines classes_and_methods

@author:     lee Ballard

@copyright:  2016. All rights reserved.

@license:    license

@contact:    ballle98@gmail.com
@deffield    updated: Updated
'''

import sys
import os
import re

from optparse import OptionParser

__all__ = []
__version__ = 0.1
__date__ = '2016-10-03'
__updated__ = '2016-10-03'

DEBUG = 1
TESTRUN = 0
PROFILE = 0

def main(argv=None):
    '''Command line options.'''

    program_name = os.path.basename(sys.argv[0])
    program_version = "v0.1"
    program_build_date = "%s" % __updated__

    program_version_string = '%%prog %s (%s)' % (program_version, program_build_date)
    program_usage = '''usage: %prog [options] in-qfx [out-qfx]'''
    program_longdesc = '''''' # optional - give further explanation about what the program does
    program_license = "Copyright 2016 lee Ballard                                            \
                Licensed under the Apache License 2.0\nhttp://www.apache.org/licenses/LICENSE-2.0"

    if argv is None:
        argv = sys.argv[1:]
    try:
        # setup option parser
        parser = OptionParser(version=program_version_string, epilog=program_longdesc, description=program_license, usage=program_usage)
        parser.add_option("-v", "--verbose", dest="verbose", action="count", help="set verbosity level [default: %default]")

        # set defaults
        parser.set_defaults(verbose=0)

        # process options
        (opts, args) = parser.parse_args(argv)

        if opts.verbose > 0:
            print("verbosity level = %d" % opts.verbose)

        # MAIN BODY #
        if len(args) < 1:
            sys.stderr.write(program_name + ": Error - must specify input QFX filename\n")
            return 2
        
        inFileName = args[0]
        if len(args) < 2:
            outFileName = os.path.splitext(inFileName)[0] + "-fixed.QFX"
        else:
            outFileName = args[1]
            
        if os.path.isfile(outFileName):
            sys.stderr.write(program_name + ": Error - file " + outFileName + " already exists\n")
            return 2

        if opts.verbose > 0:
            print("%s - %s to %s" % (program_name, inFileName, outFileName))
        
        inFile = open(inFileName, 'r')
        outFile = open(outFileName, 'w')
        outFile.write(re.sub(r'<CATEGORY>\n', '', inFile.read()))
        inFile.close()
        outFile.close()

    except Exception, e:
        indent = len(program_name) * " "
        sys.stderr.write(program_name + ": " + repr(e) + "\n")
        sys.stderr.write(indent + "  for help use --help")
        return 2


if __name__ == "__main__":
    if DEBUG:
        pass
        # sys.argv.append("-h")
    if TESTRUN:
        import doctest
        doctest.testmod()
    if PROFILE:
        import cProfile
        import pstats
        profile_filename = 'fixqfx_profile.txt'
        cProfile.run('main()', profile_filename)
        statsfile = open("profile_stats.txt", "wb")
        p = pstats.Stats(profile_filename, stream=statsfile)
        stats = p.strip_dirs().sort_stats('cumulative')
        stats.print_stats()
        statsfile.close()
        sys.exit(0)
    sys.exit(main())