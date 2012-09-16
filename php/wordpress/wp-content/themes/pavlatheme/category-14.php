<?php
get_header();
?>
    <script src="js/goodnews.js" type="text/javascript"></script>

    <div class="kataggelies-filter">
        <div class="pointerbg">ΦΙΛΤΡΟ</div>
        <div class="left filter-ddl"><select id="category" ></select></div>
        <div class="left filter-ddl"><select id="city" ></select></div>
        <div class="left filter-ddl"><select id="carrier" ></select></div>
        <div class="left filter-btn"><img onmouseover="this.src='images/btns/searchon.png'" onmouseout="this.src='images/btns/search.png'"  src="images/btns/search.png" /></div>
        <div class="clear"></div>
    </div>
    <div class="content">
        <h1 class="goodnews-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>
     
        		<div class="text">&nbsp;</div>

		<div class="goodnews">
            <div class="title">Θετικά περιστατικά</div>
            <div class="title-small grid-bg">
                <a >Οι καλύτερες υπηρεσίες</a>
            </div>
            <div class="clear"></div>
            <div class="grid">
                <div id="rpt">
                </div>
            </div>
            <div class="topten">
                <div id="rpttopten">
                </div>
            </div>
            <div class="clear"></div>
        </div>
    </div>
<?php
get_footer();
?>
