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
define('DB_NAME', 'teleia');

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
define('AUTH_KEY',         'C%<0_VbK#As)5Cju(]<+f[%cZ5@Xk6-5B*;-7OP+x*DngmWT|SFyN=[XCTt|l:t6');
define('SECURE_AUTH_KEY',  '2LGi4-hT51*k1sDjpPt#%T^ow|p]GC|bG)`DKY&.!i-zP ~[-O5l3:`*3vwx {KA');
define('LOGGED_IN_KEY',    'K.s6ICr|tYwdhSfo9GcZrfc4+$%I|ECO#LF0S~N}aZY_l6Y:avR#zeLla&%p,x[3');
define('NONCE_KEY',        ']j{vpj1^[%TtOJ p 8VRU-,3d{DySSRoe8Krhah]BWB1e#Fj(> k}Q4lS|z4x?-Y');
define('AUTH_SALT',        'FiSl,=tt}}Cmz&mK&ri5;t*i=1 YaY(D+ZJwN[x@jfs*8,#4JH<qX&JlB4*JWx6b');
define('SECURE_AUTH_SALT', '8]-Ygw3U^O#qf~3Z/[G|D3-9@}~)~xyryf9;hy$z`_^aHFeFGxP8Bvjp[8Uo}Z{D');
define('LOGGED_IN_SALT',   'XC1|3O, vr>,m(Pd DtS-J|p.%-|1t)j9=eJDn:;8:zl/|*tL?p] scM:oNf~o`d');
define('NONCE_SALT',       'x]9D#E8|60Ju6+ugThzJ.e>]]9=Mm4/$`A|*%;h1^7k%BDK*#H!=z<f,^O<=ohuC');
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
