<?php
get_header();
?>
<script src="js/top.js" type="text/javascript"></script>

    <div class="content">
        <h1 class="protoimediafora-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>
        <div class="protimefiafora-header">
            <div class="protimefiafora-title"><a>Περιστατικά</a></div>
            <div class="clear"></div>
        </div>
        <div class="text protimediafora">
            <div id="rpt">

            </div>
        </div>
        <div class="readmore">
			     <div class="starts"></div>
		            <div class="txt">Τα στοιχεία υποβάλλονται ανώνυμα και πρέπει να αφορούν προσωπική σας εμπειρία</div>
		            <div class="starts"></div>
            <div class="link"><a href="#">Μάθε περισσότερα</a></div>
        </div>
    </div>

<?php
get_footer();
?>
