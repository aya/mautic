<?php
/**
 * @package     Mautic
 * @copyright   2015 Busit. All rights reserved.
 * @author      Busit
 * @link        http://mautic.org
 * @license     GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 */
?>

<html>
  <head>
    <?php $view['assets']->outputHeadDeclarations(); ?>
  </head>
  <body style="background-color: #f5f5f5; font-family: Arial; font-size: 1em;">
    <div style="padding: 20px;">
      <div style="width: 100%; margin: 0 auto; text-align: center; padding: 0 0 10px 0;">
        <a href="http://www.busit.com">
        <img src="https://images.busit.com/logos/logo_100.png" alt="Logo Busit" />
        </a>
        <br />
        <h1 style="color: #0067b3; font-size: 1.9em; margin: 20px 0 0 0;">
        <?php $view['slots']->output('title'); ?>
	</h1>
        <h2 style="margin: 0 0 0 0; color: #979797; font-weight: normal;">
        <?php $view['slots']->output('header'); ?>
	</h2>
        <?php $view['slots']->output('body'); ?>
      </div>
      <div style="width: 90%; max-width: 800px; margin: 0 auto; padding: 20px 10px 10px 10px; background-color: #ffffff; border: 1px solid #e5e5e5; margin-bottom: 10px; line-height: 25px; text-align: left; color: #848484; text-align: center;">
        <?php $view['slots']->output('footer'); ?>
      </div>
      <div style="width: 100%; height: 50px; margin: 0 auto; color: #9f9f9f; font-size: .8em; text-align: center;">
        Copyright &copy; 2015 Busit
      </div>
    </div>
    <?php $view['slots']->output('builder'); ?>
  </body>
</html>
