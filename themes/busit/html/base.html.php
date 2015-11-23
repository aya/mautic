<?php
/**
 * @package     Mautic
 * @copyright   2014 Mautic Contributors. All rights reserved.
 * @author      Busit
 * @link        http://mautic.org
 * @license     GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 */
?>
<!DOCTYPE html>
<html>
    <head>
	<title><?php $view['slots']->output('pageTitle', 'Mautic'); ?></title>
        <?php if (isset($page)) : ?>
            <meta name="description" content="<?php echo $page->getMetaDescription(); ?>">
        <?php endif; ?>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" />
	<meta name="viewport" content="width=device-width,initial-scale=1" />
        <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min.js"></script>
	<link rel="shortcut icon" href="//images.busit.com/favicon.ico" />
        <link rel="stylesheet" href="//www.busit.com/css/busit-index.css"/>
        <link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css" type="text/css" />
        <link href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
        <link rel="stylesheet" href="<?php echo $view['assets']->getUrl('themes/busit/css/busit.css'); ?>" type="text/css" />
        <?php $view['assets']->outputHeadDeclarations(); ?>
    </head>
    <body>
        <?php $view['assets']->outputScripts("bodyOpen"); ?>
        <?php $view['slots']->output('_content'); ?>
        <?php $view['assets']->outputScripts("bodyClose"); ?>
    </body>
</html>
