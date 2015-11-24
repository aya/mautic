<?php
/**
 * @package     Mautic
 * @copyright   2014 Mautic Contributors. All rights reserved.
 * @author      Mautic
 * @link        http://mautic.org
 * @license     GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 */
$view->extend(":$template:base.html.php");
$parentVariant = $page->getVariantParent();
$title         = (!empty($parentVariant)) ? $parentVariant->getTitle() : $page->getTitle();
$view['slots']->set('public', (isset($public) && $public === true) ? true : false);
$view['slots']->set('pageTitle', $title);
?>
<div class="top">
    <div class="head">
        <nav class="navbar navbar-default navbar-static-top" role="navigation">
            <div class="container">
                <div class="navbar-header">
                    <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" style="margin-top: 20px;">
                        <span class="sr-only">Toggle navigation</span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                        <span class="icon-bar"></span>
                    </button>
                    <a class="navbar-brand" href="//www.busit.com" style="height: 80px;">
                        <img src="//images.busit.com/logos/logo_white.png" alt="logo"/></a>
                    </a>
                </div>
                <div class="collapse navbar-collapse" id="navbar">
                    <ul class="nav navbar-nav navbar-right">
                        <li style="padding-top: 18px;"><a class="" href="//www.busit.com/professional/">Professionels</a></li>
                        <li style="padding-top: 18px;"><a class="" href="//www.busit.com/store/">BusApps</a></li>
                        <li style="padding-top: 18px;"><a class="" href="//www.busit.com/offer/">Offres</a></li>
                        <li style="padding-top: 18px;"><a class="" href="//www.busit.com/demo/">Explorer</a></li>
                        <li style="padding-top: 18px;"><a class="menuseparation" href="//www.busit.com/private/panel/">&nbsp;&nbsp;Mon compte</a></li>
                    </ul>
                </div>
            </div>
        </nav>
    </div>
</div>
<div class="container grey">
<?php if ($view['slots']->hasContent(array('top'))): ?>
    <div class="row">
    <?php if ($view['slots']->hasContent('top')): ?>
        <div class="col-xs-12"><?php $view['slots']->output('top'); ?></div>
    <?php endif; // end of top1 ?>
    </div>
<?php endif; // end of Top check ?>

<?php if ($view['slots']->hasContent(array('left', 'main'))): ?>
    <div class="row">
        <?php if ($view['slots']->hasContent(array('left'))): ?>
        <div class="col-xs-12 col-sm-4">
            <?php if ($view['slots']->hasContent('left')): ?>
            <!-- div class="row"-->
                <div class="col-xs-12">
                    <?php $view['slots']->output('left'); ?>
                </div>
            <!--/div-->
            <?php endif; // end of left1 ?>
        </div>
        <?php endif; // end of Left check ?>

        <?php if ($view['slots']->hasContent('main')): ?>
        <div class="col-xs-12 col-sm-8">
            <?php $view['slots']->output('main'); ?>
        </div>
        <?php endif; // end of main ?>
    </div>
<?php endif; // end of Center check ?>

<?php if ($view['slots']->hasContent(array('bottom'))): ?>
    <div class="main-block bg-primary row">
        <?php if ($view['slots']->hasContent('bottom')): ?>
        <div class="col-xs-12"><?php $view['slots']->output('bottom'); ?></div>
        <?php endif; // end of bottom1 ?>
    </div>
<?php endif; // end of Bottom check ?>

<?php if ($view['slots']->hasContent('footer')): ?>
    <div class="row">
        <div class="col-xs-12"><?php $view['slots']->output('footer'); ?></div>
    </div>
<?php endif; // end of footer ?>
    
</div>
<div class="footer" style="background-color: #ffffff;">
	<div class="content">
		<div class="social">
			<a class="link" href="https://twitter.com/Bus_IT">
				<img src="//images.busit.com/social/twitter.png" alt="Twitter" />
			</a>
			<a class="link" href="https://www.facebook.com/busit.net">
				<img src="//images.busit.com/social/facebook.png" alt="Facebook" />
			</a>
			<a class="link" href="https://plus.google.com/+BusitFr" rel="publisher">
				<img src="//images.busit.com/social/google.png" alt="Google+" />
			</a>
			<a class="link" href="https://www.linkedin.com/company/5121205">
				<img src="//images.busit.com/social/linkedin.png" alt="LinkedIn" />
			</a>
			<a class="link" href="http://www.youtube.com/channel/UCvB9PQcyRzdf8n4AewdE_oA">
				<img src="//images.busit.com/social/youtube.png" alt="YouTube" />
			</a>
			<div class="clearfix"></div>
		</div>
		<br />
		<ul>
                        <li><a href="//community.busit.com/">Communaut&eacute;</a></li>
                        <li><a href="//www.busit.com/blog/">Blog</a></li>
                        <li><a href="//www.busit.com/developers/">D&eacute;veloppeurs</a></li>
                        <li><a href="//www.busit.com/partners/">Partenaires</a></li>
                </ul>
                <ul class="footersecondary" style="margin-top: 10px;">
                        <li><a href="//www.busit.com/about/">A propos</a></li>
                        <li><a href="//www.busit.com/press/">Presse</a></li>
                        <li><a href="//www.busit.com/contact/">Contact</a></li>
                        <li><a href="//www.busit.com/team/">Equipe</a></li>
                        <li><a href="//www.busit.com/legal/">Légal</a></li>
		</ul>
		<p style="margin: 10px 0 0 0; padding: 0; font-size: 0.7em;">
			<a href="//www.busit.com/?_locale=en_US">English</a>&nbsp;&nbsp;&nbsp;
			<a href="//www.busit.com/?_locale=fr_FR">Français</a>&nbsp;&nbsp;&nbsp;
                        <!--a href="//www.busit.com/?_locale=es_ES">Espa&ntilde;ol</a-->
		</p>
		<p style="font-size: 0.8em; font-weight: bold;">&copy; 2015 <a href='//www.busit.com'>Busit</a></p>
	</div>
</div>
<?php $view['slots']->output('builder'); ?>
