import bibtexparser as bp
import sys

def isequal(e1, e2):
    keys1 = e1.fields_dict.keys()
    keys2 = e2.fields_dict.keys()
    shared_keys = keys1 & keys2
    for k in shared_keys:
        if e1.fields_dict[k].value != e2.fields_dict[k].value:
            return False
    return True

def update_refs_bib():
    '''
    interactively dedupes refs.bib
    '''
    library = bp.parse_file('refs.bib')
    print('library had %d entries' % len(library.entries))

    # dupe keys
    dupes = [b for b in library.blocks
               if isinstance(b, bp.model.DuplicateBlockKeyBlock)]
    library.remove(dupes)

    # smarter deduping?
    dupes = []
    for idx, e1 in enumerate(library.entries):
        for idx2, e2 in enumerate(library.entries[idx + 1: ]):
            if isequal(e1, e2):
                dupes.append((idx, idx2 + idx + 1))
    rm_lst = []
    for idx1, idx2 in dupes:
        print()
        print(library.entries[idx1])
        print()
        print(library.entries[idx2])
        print()
        while True:
            idx = int(input('Which to delete (1/2)? '))
            if idx == 1:
                rm_lst.append(library.entries[idx1])
                break
            elif idx == 2:
                rm_lst.append(library.entries[idx2])
                break
            else:
                print('invalid, try again')

    print('found %d dupes, removing' % len(rm_lst))
    library.remove(rm_lst)
    with open('refs.bib', 'w') as f:
        bp.write_file(f, library)

def merge_bib2():
    fn = sys.argv[1]
    lib1 = bp.parse_file('refs.bib')
    print('lib1 had %d entries' % len(lib1.entries))
    lib2 = bp.parse_file(fn)
    print('newlib had %d entries' % len(lib2.entries))
    for e2 in lib2.entries:
        for e1 in lib1.entries:
            if isequal(e1, e2):
                if e1.key != e2.key:
                    print('WARN: Two entries with identical contents but '
                          'differentkeys, old/new are (%s/%s)'
                          % (e1.key, e2.key))
                break
        else:
            lib1.add(e2)
    print('lib1 now has %d entries' % len(lib1.entries))
    with open('refs.bib', 'w') as f:
        bp.write_file(f, lib1)

if __name__ == '__main__':
    # update_refs_bib()
    merge_bib2()
