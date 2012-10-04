<?php
get_header();


?>
<div style="visibility:hidden" >
	   <input type="hidden" id="public_entity_selected_value" value="<?php echo $_GET['entity_id'] ?>" />
</div>

<script src="js/complaint.js" type="text/javascript"></script>



<div class="kataggelies-filter">
    <div class="pointerbg">ΦΙΛΤΡΟ</div>
    <div class="left filter-ddl"><select id="category" ></select></div>
    <div class="left filter-ddl"><input class="searchinput" type="text" id="place" value="Περιοχή / Πόλη" onclick="ClearTxt(this,'Περιοχή / Πόλη')" onblur="ResetTxt(this,'Περιοχή / Πόλη')"/></div>
    <div class="left filter-ddl">

		<input class="searchinput" type="text" id="public_entity" value="Υπηρεσία / Οργανισμός" onclick="ClearTxt(this,'Υπηρεσία / Οργανισμός')" onblur="ResetTxt(this,'Υπηρεσία / Οργανισμός')"/></div>
    <div class="left filter-btn"><img onmouseover="this.src='images/btns/searchon.png'" onmouseout="this.src='images/btns/search.png'"  src="images/btns/search.png" onclick="doSearch();"/></div>
    <div class="clear"></div>
</div>
<div class="content">
    <h1 class="protoimediafora-icon"><?php echo single_cat_title( $category_id ); ?></h1>
    <div class="subtext"><?php echo category_description( $category_id );  ?></div>


    <div class="kataggelies">
        <div class="title" id="incidents_title">Περιστατικά</div>
        <div class="title-small grid-bg">
            <a class="asked">Ζητήθηκε</a>
            <a class="given">Δόθηκε</a>
        </div>
        <div class="clear"></div>
        <div class="grid">
            <div id="rpt">
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    if ($('#public_entity_selected_value').val() != '') { $('#public_entity').val('<?php echo $_GET['entity'] ?>'); }
</script>


<?php
get_footer();
?>
