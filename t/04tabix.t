# Copyright [1999-2016] EMBL-European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

use strict;
use warnings;
use Test::More tests => 13, 'die';
use feature qw( say );
use FindBin qw( $Bin );

BEGIN { use_ok 'Bio::DB::HTS::Tabix'; }

my $test_file = $Bin . '/data/test.tsv.gz';

my $tbx = Bio::DB::HTS::Tabix->new( filename => $test_file, warnings => 0 );
my $h = $tbx->header ;
ok( $h, "#CHROM  FROM    TO      GERP" ) ;
my @ha = $tbx->header_array ;
ok( $ha[0], "#CHROM  FROM    TO      GERP" ) ;

ok my $iter = $tbx->query("12:8000000-8000008"), "can query a region";

#make sure we can call next
ok my $row = $iter->next, 'can get a value from the iterator';
is $row, "12\t8000000\t8000000\t-2.94", 'row value is correct';

my $num_rows = 0;
++$num_rows while $iter->next;
is $num_rows, 7, "correct number of values come back from the iterator";

#check seqnames
my $seqnames = $tbx->seqnames;
isa_ok($seqnames, 'ARRAY');
is_deeply $seqnames, [1, 12, 'X'], 'seqnames are correct';

ok $iter = $tbx->query("fake"), 'non existent chrom works fine';
is $iter->next, undef, 'iterator for missing chrom is fine';
$tbx->close;

#More in depth header tests
$test_file = $Bin . '/data/data.vcf.gz';
$tbx = Bio::DB::HTS::Tabix->new( filename => $test_file, warnings => 0 );
@ha = $tbx->header_array ;
ok( $ha[0], "##fileformat=VCFv4.2" ) ;
ok( $ha[5], "##reference=human_b36_both.fasta" ) ;
$tbx->close;

done_testing;
