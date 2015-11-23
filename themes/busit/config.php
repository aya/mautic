<?php
/**
 * @package     Mautic
 * @copyright   2014 Mautic Contributors. All rights reserved.
 * @author      Busit
 * @link        http://mautic.org
 * @license     GNU/GPLv3 http://www.gnu.org/licenses/gpl-3.0.html
 */

$config = array(
    "name"        => "Busit",
    "features"    => array(
        "page",
        "email",
        "form"
    ),
    "slots"       => array(
        "page" => array(
            "top",
            "left",
            "main",
            "bottom",
            "footer"
        ),
        "email" => array(
            "title",
            "header",
            "body",
            "footer"
        )
    )
);

return $config;
