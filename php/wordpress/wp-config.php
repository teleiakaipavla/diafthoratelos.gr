<?php
/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, WordPress Language, and ABSPATH. You can find more information
 * by visiting {@link http://codex.wordpress.org/Editing_wp-config.php Editing
 * wp-config.php} Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', 'teleiakaipavla');

/** MySQL database username */
define('DB_USER', 'root');

/** MySQL database password */
define('DB_PASSWORD', 'root');

/** MySQL hostname */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         '$?XKC%e{+C4PKxVyQ~.DzC/oqF<(nIqf[B/a[>+0#/%j2Wd3)B!l>1v6?1K/T{t;');
define('SECURE_AUTH_KEY',  'QWpJ_om.JK5KprfCwLA~RkgN<i}40HuwJL#S$#-u20)^F.tXF6=2C6 !/o4qk6$C');
define('LOGGED_IN_KEY',    '^0<:fB-0qDZnD$o+tnRHv+qvtu!V~X|oXEI[Poq8]Y:1TfI_rJR665+xzHLD#P<J');
define('NONCE_KEY',        '0!-Gtg(*J_t#(=HOn~clusi|0+CsXed/u2Hi60qhhr$CRgF[E+O2DRU9V7 V}S)$');
define('AUTH_SALT',        'NWQ`h$RR(0!,o_6I.+^5VmV;}&ZMIH=!^]#Y+)14_O {?j!Qo^uyi(pLv6.ZYF;9');
define('SECURE_AUTH_SALT', '#+>MS-_+Te6Z{!t%A[A;Aw=eYZX4RS9 0:-A5=)%s T+DP-bF*,Z_t;0d.)QfKm+');
define('LOGGED_IN_SALT',   '~y2-TH=N{aRN[^&oR87h0gs[ey %@ysA{=G#Q+=-p+pV,RXoAw.komPo<A3]@K$r');
define('NONCE_SALT',       'Zzi#C$(XKIg4xef$dgP6?0Z]kNBHb*O}4/TRh>Yi-bw$9v._+RLal2lHiPiI5%y|');

/**#@-*/

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix  = 'wp_';

/**
 * WordPress Localized Language, defaults to English.
 *
 * Change this to localize WordPress. A corresponding MO file for the chosen
 * language must be installed to wp-content/languages. For example, install
 * de_DE.mo to wp-content/languages and set WPLANG to 'de_DE' to enable German
 * language support.
 */
define('WPLANG', '');

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', false);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
