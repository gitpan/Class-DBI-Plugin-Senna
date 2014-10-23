#!perl
use strict;

BEGIN
{
    require Test::More;
    if (! eval { require DBD::SQLite }) {
        Test::More->import(skipall => 'DBD::SQLite not available');
    } else {
        Test::More->import(tests => 6);
    }
}

package MyDATA;
use strict;
use base qw(Class::DBI);
use Class::DBI::Plugin::Senna
    index_filename => 't/test_index',
    index_column   => 'data'
;
__PACKAGE__->set_db(Main => 'dbi:SQLite:dbname=t/test.db', undef, undef, { AutoCommit => 1});
__PACKAGE__->table('MyDATA');
__PACKAGE__->columns(All => qw(id data));

1;

package main;
use strict;

MyDATA->db_Main->do(qq{
    CREATE TABLE MyDATA (
        id PRIMARY KEY,
        data TEXT
    );
});

my $id = 'a';
while (<DATA>) {
    chomp;
    MyDATA->create({ id => $id++, data => $_ });
}

my $iter = MyDATA->fulltext_search("���ޤä�");
isa_ok($iter, 'Class::DBI::Plugin::Senna::Iterator');
is($iter->count, 2);
while (my $e = $iter->next) {
    ok($e);
}

my $obj = MyDATA->retrieve('b');
$obj->data("���Ť�θ���ˤ������桢���ᤢ�ޤ����֤�Ҥ��ޤҤ���ʤ��ˡ����Ȥ�ऴ�Ȥʤ��ݤˤϤ���̤���������ƻ��᤭���ޤդ��ꤱ�ꡣ");
$obj->update;

my($rs) = MyDATA->fulltext_search("������ƻ��᤭���ޤդ��ꤱ��");
is($rs && $rs->id, 'b');

if ($rs) {
    $rs->delete;
    ($rs) = MyDATA->fulltext_search("������ƻ��᤭���ޤդ��ꤱ��");
    ok(!$rs);
} else {
    ok(0);
}

END {
    eval {MyDATA->senna_index->remove};
    eval {unlink("t/test.db")};
}
__DATA__
�������ˤξ����������̵��ζ������ꡣհ���м��β֤ο�������ɬ������򤢤�魯���������ͤ�פ����餺��ͣ�դ����̴�Τ��Ȥ����������Ԥ��ˤϤۤ�Ӥ̡��Ф��������οФ�Ʊ����
�������ʤ��礦�����ˡ����β��ϡʤ����⤦�ˡ��¤μ��ˡʤ��夤�ˡ����Ͻ���ʤ�����ݰ�Ͻ���ˤ������Ĥ������˽��鷺���ڤ��ߤ򤭤���ݸ���ʹ������ŷ���������Τ餺��̱����ͫ����ܤߤʤ��Τ�˴�ӤƤ��ޤä���
�椬��Ǥ⡢��ʿ��ʿ���硢ŷ�Ĥ�ƣ����ͧ�ʤ��ߤȤ�ˡ����¤θ����ơʤ褷�����ˡ�ʿ����ƣ������ʤΤ֤��ˡ�������ޤ�ʤ�˴�ӤƤ��ޤä���
�Ƕ�Ǥϡ�ϻ�������ƻ���������ʿī���������Ȥ����ͤ�ͭ�ͤ�ʹ���ȡ����դˤǤ��ʤ��ۤɤ���
�������Ĥϴ���ŷ�Ĥ���ޤιĻҡ����ʼ������븶�ʤ�����Ϥ�˿Ʋ��ζ���λ�¹�ˤ����뻾���������ʤ��̤��Τ��ߤޤ����ˤλ�¹�Ǥ��ꡢ�����������ʤ�������ī�ä����ˤǤ��롣���οƲ��λҡ���벦�ʤ����ߤ����ˤ�̵��̵�̤Ǥ��������λҹ�˾���ʤ�����������ˤΤȤ�����ʿ�������äƾ����ˤʤ�ޤ�������������²��Ϥʤ�ƿͿä�Ϣ�ʤä������λҤ��ü��ܾ�����˾�ʤ褷�������˹��ʤ��ˤ��ˤ�̾����᤿���ˤ��������ޤǤ�ϻ��δ֤ϡ�����μ��ΤǤ��ä���������˾��¤������ʤ��ä���
