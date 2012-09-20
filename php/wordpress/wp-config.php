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
define('DB_NAME', 'telia');

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
define('AUTH_KEY',         'Y.)P|@G$XUW>g6o8Oy+sQ-s3C.g TZl+B!3qw63Ye[ZP*I.S36f4zctM3M}Yj_V>');
define('SECURE_AUTH_KEY',  '(p>r$P75Qh+$!MzW%Whkja(~]nj^@ZnI8D@Y=mE|($7CrQJE+QY7lQ&2WS|0/<=~');
define('LOGGED_IN_KEY',    'gYSE*^+3OeB]N@HQ><$u-`$vDBp/SQZJ!,yACxurAjIRn/c~~^zSe|{q7:E4mgFa');
define('NONCE_KEY',        'p(rB4f0SYw|do|b|snv@MJQ2GxrNA` Ip7P3t^+mH@gP.|1eG-qZnW81|Dv.igly');
define('AUTH_SALT',        'D/|[DKVf#LY4ljg+UgsQ)G~i-i.B#a,qmHl0#28yb4=!*::gXPg{vF i2f5D 07i');
define('SECURE_AUTH_SALT', 'qv~@n=H%xI[0V~Nm|Ac{b11;zj+P-ZwM<jW)g`25L*PO(tx~c 0{xQ2q)=LEF;cx');
define('LOGGED_IN_SALT',   '369 58.?$Z66Z8NTr|HG*U7UP<f@7/e3v^C~#6 W|y4z:l|%9Cq8Uv`5?*Lekwig');
define('NONCE_SALT',       '(uKiz^cCspYDO,7&*JBt(b?-#n$OG(anh/bpt<r`wOqK1+AmpK#X_y=MK^oL}:|U');

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
