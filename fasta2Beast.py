import sys

def fasta_to_xml(fasta_path):
    with open(fasta_path) as f:
        name, seq = None, []
        for line in f:
            line = line.strip()
            if line.startswith(">"):
                if name:
                    print(f'<sequence id="{name}" taxon="{name}" totalcount="4" value="{ "".join(seq) }"/>')
                name = line[1:]
                seq = []
            else:
                seq.append(line)
        if name:
            print(f'<sequence id="{name}" taxon="{name}" totalcount="4" value="{ "".join(seq) }"/>')

if __name__ == "__main__":
    fasta_to_xml(sys.argv[1])
