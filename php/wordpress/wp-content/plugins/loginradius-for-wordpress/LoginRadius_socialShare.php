<?php 
  	add_action('wp_head', 'loginradius_share_output');
	
	if($LoginRadius_settings['LoginRadius_sharehome'] || $LoginRadius_settings['LoginRadius_sharepost'] || $LoginRadius_settings['LoginRadius_sharepage'] || $LoginRadius_settings['LoginRadius_shareexcerpt'] || $LoginRadius_settings['LoginRadius_sharearchive'] || $LoginRadius_settings['LoginRadius_sharefeed'])
	{
		function add_post_content($content) 
		{
			global $LoginRadius_settings;
			
			$append = "<label><b>".ucfirst($LoginRadius_settings['LoginRadius_share_title'])."</b></label><br/><div class='loginradiusshare'></div>";
				
			if( ( $LoginRadius_settings['LoginRadius_sharehome'] && is_front_page() ) || ( $LoginRadius_settings['LoginRadius_sharepost'] && is_single() ) || ( $LoginRadius_settings['LoginRadius_sharepage'] && is_page() ) || ( $LoginRadius_settings['LoginRadius_shareexcerpt'] && has_excerpt() ) || ( $LoginRadius_settings['LoginRadius_sharearchive'] && is_archive() ) || ( $LoginRadius_settings['LoginRadius_sharefeed'] && is_feed() ) )
			{	
			
				if($LoginRadius_settings['LoginRadius_sharetop'] && $LoginRadius_settings['LoginRadius_sharebottom'])
				{
					$content = $append.'<br/>'.$content.'<br/>'.$append;
				}
				else
				{
					if($LoginRadius_settings['LoginRadius_sharetop'])
					{
						$content = $append.$content;
					}
					elseif($LoginRadius_settings['LoginRadius_sharebottom'])
					{
						$content = $content.$append;
					}
				}
			}
		  return $content;
		}
		add_filter('the_content', 'add_post_content');
	}
	
