/**
 * Define a grammar called Hello
 */
grammar DrRacket;

@header
{
	import static org.apache.commons.lang3.StringEscapeUtils.escapeXml;
  	import java.util.List;
}

@parser::members
{
	
  public boolean hasCommentsBefore(Token token) {
  	List<Token> hiddenTokens = ((CommonTokenStream) getTokenStream()).
			getHiddenTokensToLeft(token.getTokenIndex(),Token.HIDDEN_CHANNEL);
	if (hiddenTokens == null)
		return false;
	else
		return !hiddenTokens.isEmpty();
  }

  public String commentsBefore(Token token) {
  	StringBuilder result = new StringBuilder();
	for (Token commentToken : ((CommonTokenStream) getTokenStream()).
								getHiddenTokensToLeft(token.getTokenIndex(), Token.HIDDEN_CHANNEL)) {
		result.append(commentToken.getText()).append("\n");
	}
	return result.toString(); 	
  }
  
  public void comments(Token token) {
  	if (hasCommentsBefore(token))
		xml.append("<comment>" + escapeXml(commentsBefore(token)) + "</comment>");
  }
  
  public final StringBuilder xml = new StringBuilder();
}


start : HASH_ID
{
	xml.append("<?xml version='1.0' encoding='UTF-8' standalone='yes'?>");
	xml.append("<drracket>");
	comments($HASH_ID);
	xml.append("<conf lang='" + escapeXml($HASH_ID.text) + "'/>" );
}
expr* 
{
	xml.append("</drracket>");
};

expr : terminal | string_terminal | hash_terminal| round_paren | square_paren | quote | quasiquote | unquote | vector;

terminal : ID
{
	comments($ID);
	xml.append("<terminal value='" + escapeXml($ID.text) + "' line='" + $ID.line+ "'/>");
} ;

string_terminal : STRING
{
	comments($STRING);
	xml.append("<terminal value='" + escapeXml($STRING.text) + "' sline='" + $STRING.line+ "'/>");
} ;

hash_terminal : HASH_ID
{
	comments($HASH_ID);
	xml.append("<terminal value='" + escapeXml($HASH_ID.text) + "' line='" + $HASH_ID.line+ "'/>");
} ;

round_paren : t='(' 
{
	comments($t);
	xml.append("<paren type='round' line='" + $t.line+ "'>");
}
expr*

')'
{
	xml.append("</paren>");
} ;

square_paren : t='[' 
{
	comments($t);
	xml.append("<paren type='square' line='" + $t.line+ "'>");
}
expr*

']'
{
	xml.append("</paren>");
} ;

quote : t='\'' 
{
	comments($t);
	xml.append("<quote line='" + $t.line+ "'>");
}
expr
{
	xml.append("</quote>");
} ;

quasiquote : t='`' 
{
	comments($t);
	xml.append("<quasiquote line='" + $t.line+ "'>");
}
expr
{
	xml.append("</quasiquote>");
} ;

unquote : t=',' 
{
	comments($t);
	xml.append("<unquote line='" + $t.line+ "'>");
}
expr
{
	xml.append("</unquote>");
} ;

vector : t='#' 
{
	comments($t);
	xml.append("<vector line='" + $t.line+ "'>");
}
expr
{
	xml.append("</vector>");
} ;



ID : ~[",'`()[\]{}|;#\p{White_Space}]+;

HASH_ID : '#' ID;

STRING: '"' ( '""' | ~["] )* '"';

WS : [\p{White_Space}]+ -> skip;

COMMENT
  :  ';' ~[\r\n]* -> channel(HIDDEN);