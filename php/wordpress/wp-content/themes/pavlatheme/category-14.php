<?php
get_header();
?>
    <script src="js/goodnews.js" type="text/javascript"></script>

    <div class="kataggelies-filter">
        <div class="pointerbg">ΦΙΛΤΡΟ</div>
        <div class="left filter-ddl"><select id="category" ></select></div>
        <div class="left filter-ddl"><input class="searchinput" type="text" id="city" value="Περιοχή / Πόλη" onclick="ClearTxt(this,'Περιοχή / Πόλη')" onblur="ResetTxt(this,'Περιοχή / Πόλη')"/></div>
        <div class="left filter-ddl"><input class="searchinput" type="text" id="carrier" value="Υπηρεσία / Οργανισμός" onclick="ClearTxt(this,'Υπηρεσία / Οργανισμός')" onblur="ResetTxt(this,'Υπηρεσία / Οργανισμός')"/></div>
        <div class="left filter-btn"><img onmouseover="this.src='images/btns/searchon.png'" onmouseout="this.src='images/btns/search.png'"  src="images/btns/search.png" onclick="BindGrid(true);"/></div>
        <div class="clear"></div>
    </div>
    <div class="content">
        <h1 class="goodnews-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>
     
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
