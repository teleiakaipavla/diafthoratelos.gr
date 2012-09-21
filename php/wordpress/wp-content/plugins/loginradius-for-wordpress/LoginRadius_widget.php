<?php
class LoginRadiusWidget extends WP_Widget {
	/** constructor */
	function LoginRadiusWidget() {
		parent::WP_Widget(
			'LoginRadius', //unique id
			'Login Radius', //title displayed at admin panel
			//Additional parameters
			array( 
				'description' => __( 'Login or register with Facebook, Twitter, Yahoo, Google and many more', 'LoginRadius' ))
			);
	}

	/** This is rendered widget content */
	function widget( $args, $instance ) {
		extract( $args );
		
		if($instance['hide_for_logged_in']==1 && is_user_logged_in()) return;
		
		echo $before_widget;

		if( !empty( $instance['title'] ) ){
			$title = apply_filters( 'widget_title', $instance[ 'title' ] );
			echo $before_title . $title . $after_title;
		}

		if( !empty( $instance['before_widget_content'] ) ){
			echo $instance['before_widget_content'];
		}

		Login_Radius_widget_Connect_button() ;

		if( !empty( $instance['after_widget_content'] ) ){
			echo $instance['after_widget_content'];
		}

		echo $after_widget;
	}

	/** Everything which should happen when user edit widget at admin panel */
	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['before_widget_content'] = $new_instance['before_widget_content'];
		$instance['after_widget_content'] = $new_instance['after_widget_content'];
		$instance['hide_for_logged_in'] = $new_instance['hide_for_logged_in'];

		return $instance;
	}

	/** Widget edit form at admin panel */
	function form( $instance ) {
		/* Set up default widget settings. */
		$defaults = array( 'title' => 'Please Login with', 'before_widget_content' => '', 'after_widget_content' => '' );

		foreach( $instance as $key => $value ) 
			$instance[ $key ] = esc_attr( $value );

		$instance = wp_parse_args( (array)$instance, $defaults );
		?>
		<p>
			<label for="<?php echo $this->get_field_id( 'title' ); ?>"><?php _e( 'Title:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" type="text" value="<?php echo $instance['title']; ?>" />
			<label for="<?php echo $this->get_field_id( 'before_widget_content' ); ?>"><?php _e( 'Before widget content:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'before_widget_content' ); ?>" name="<?php echo $this->get_field_name( 'before_widget_content' ); ?>" type="text" value="<?php echo $instance['before_widget_content']; ?>" />
			<label for="<?php echo $this->get_field_id( 'after_widget_content' ); ?>"><?php _e( 'After widget content:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'after_widget_content' ); ?>" name="<?php echo $this->get_field_name( 'after_widget_content' ); ?>" type="text" value="<?php echo $instance['after_widget_content']; ?>" />
			<br /><br /><label for="<?php echo $this->get_field_id( 'hide_for_logged_in' ); ?>"><?php _e( 'Hide for logged in users:', 'LoginRadius' ); ?></label>
	<input type="checkbox" id="<?php echo $this->get_field_id( 'hide_for_logged_in' ); ?>" name="<?php echo $this->get_field_name( 'hide_for_logged_in' ); ?>" type="text" value="1" <?php if($instance['hide_for_logged_in']==1) echo 'checked="checked"'; ?> />
		</p>
<?php
  }
}
add_action( 'widgets_init', create_function( '', 'return register_widget( "LoginRadiusWidget" );' ));
class LoginRadiusShareWidget extends WP_Widget {
	/** constructor */
	function LoginRadiusShareWidget() {
		parent::WP_Widget(
			'LoginRadiusShare', //unique id
			'Login Radius Share', //title displayed at admin panel
			//Additional parameters
			array( 
				'description' => __( 'Share post/page with Facebook, Twitter, Yahoo, Google and many more', 'LoginRadius' ))
			);
	}

	/** This is rendered widget content */
	function widget( $args, $instance ) {
		extract( $args );
		
		if($instance['hide_for_logged_in']==1 && is_user_logged_in()) return;
		
		echo $before_widget;

		if( !empty( $instance['title'] ) ){
			$title = apply_filters( 'widget_title', $instance[ 'title' ] );
			echo $before_title . $title . $after_title;
		}

		if( !empty( $instance['before_widget_content'] ) ){
			echo $instance['before_widget_content'];
		}
        
		echo '<div class="loginradiusshare"></div>';

		if( !empty( $instance['after_widget_content'] ) ){
			echo $instance['after_widget_content'];
		}

		echo $after_widget;
	}

	/** Everything which should happen when user edit widget at admin panel */
	function update( $new_instance, $old_instance ) {
		$instance = $old_instance;
		$instance['title'] = strip_tags( $new_instance['title'] );
		$instance['before_widget_content'] = $new_instance['before_widget_content'];
		$instance['after_widget_content'] = $new_instance['after_widget_content'];
		$instance['hide_for_logged_in'] = $new_instance['hide_for_logged_in'];

		return $instance;
	}

	/** Widget edit form at admin panel */
	function form( $instance ) {
		/* Set up default widget settings. */
		$defaults = array( 'title' => 'Share it now', 'before_widget_content' => '', 'after_widget_content' => '' );

		foreach( $instance as $key => $value ) 
			$instance[ $key ] = esc_attr( $value );

		$instance = wp_parse_args( (array)$instance, $defaults );
		?>
		<p>
			<label for="<?php echo $this->get_field_id( 'title' ); ?>"><?php _e( 'Title:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'title' ); ?>" name="<?php echo $this->get_field_name( 'title' ); ?>" type="text" value="<?php echo $instance['title']; ?>" />
			<label for="<?php echo $this->get_field_id( 'before_widget_content' ); ?>"><?php _e( 'Before widget content:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'before_widget_content' ); ?>" name="<?php echo $this->get_field_name( 'before_widget_content' ); ?>" type="text" value="<?php echo $instance['before_widget_content']; ?>" />
			<label for="<?php echo $this->get_field_id( 'after_widget_content' ); ?>"><?php _e( 'After widget content:', 'LoginRadius' ); ?></label>
			<input class="widefat" id="<?php echo $this->get_field_id( 'after_widget_content' ); ?>" name="<?php echo $this->get_field_name( 'after_widget_content' ); ?>" type="text" value="<?php echo $instance['after_widget_content']; ?>" />
			<br /><br /><label for="<?php echo $this->get_field_id( 'hide_for_logged_in' ); ?>"><?php _e( 'Hide for logged in users:', 'LoginRadius' ); ?></label>
	<input type="checkbox" id="<?php echo $this->get_field_id( 'hide_for_logged_in' ); ?>" name="<?php echo $this->get_field_name( 'hide_for_logged_in' ); ?>" type="text" value="1" <?php if($instance['hide_for_logged_in']==1) echo 'checked="checked"'; ?> />
		</p>
<?php
  }
}
add_action( 'widgets_init', create_function( '', 'return register_widget( "LoginRadiusShareWidget" );' ));
?>