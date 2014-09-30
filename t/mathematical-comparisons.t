use Test::More tests => 3;

BEGIN { use_ok 'HTML::Strip' }

# test for RT#35345
{
    my $hs = HTML::Strip->new();
    is( $hs->parse( <<EOF ), "\nHello\n", "mathematical comparisons in strip tags bug RT#35345" );
<script>
function shovelerMain (detectBuyBox) {
    for (var i = 0; i < Shoveler.Instances.length; i++) {
...
</script>
<h1>Hello</h1>
EOF
    $hs->eof;
}

# test for RT#99207
{
    my $hs = HTML::Strip->new();
    is( $hs->parse( <<EOF ), "\nhallo\n", "mathematical comparisons in strip tags bug RT#99207" );
<script type="text/javascript">
    document.write('<scr'+'ipt src="//www3.smartadserver.com/call/pubj/' + sas_config.pageid + '/' + formatid + '/' + sas_config.master + '/' + sas_config.tmstp + '/' + encodeURIComponent(target) + '?"></scr'+'ipt>');
</script>
<span>hallo</span>
EOF
    $hs->eof;
}

