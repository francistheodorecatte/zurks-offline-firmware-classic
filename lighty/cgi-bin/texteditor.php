<?php

// configuration
$url = '/cgi-bin/texteditor.php';
$file = '/foo';

// check if form has been submitted
if (isset($_POST['text']))
{
    // save the text contents
    file_put_contents($file, base64_decode($_POST['text']));

    // redirect to form again
    header(sprintf('Location: %s', $url));
    printf('<a href="%s">Moved</a>.', htmlspecialchars($url));
    exit();
}

// read the textfile
$text = file_get_contents($file);

?>
<!-- HTML form -->
<form action="" name="spark" method="post">
<script type="text/javascript" src="/webtoolkit.base64.js"></script>
<textarea name="text2"  rows="43" cols="160"><?php echo htmlspecialchars($text) ?></textarea><br>
<input type="hidden" name="text" value=""/>
<input type="button" value="Submit"  onclick="document.spark.text.value=Base64.encode(document.spark.text2.value);document.spark.submit();"/>
<input type="reset" />
</form>

