import std.stdio;
import std.array;
import std.ascii;
import std.conv;
import std.exception;
import std.format;

enum TokenType {
    PLUS,
    MINUS,
    MUL,
    DIV,
    LPAREN,
    RPAREN,
    NUMBER
}

class Token {
public:
    this(TokenType type, string token, size_t pos) {
        this.type = type;
        this.token = token;
        this.pos = pos;
    }
    
    TokenType type;
    string token;
    size_t pos;
}

Token[] tokenize(string source) {
    Token[] tokens;
    size_t pos = 0;
    
    while(pos < source.length) {  
        if(source[pos].isWhite) {
            ++pos;
            continue;
        } else if(source[pos].isDigit) {
            size_t start = pos;
            while(pos < source.length && source[pos].isDigit) {
                ++pos;
            }
            string number = source[start..pos];
            tokens ~= new Token(TokenType.NUMBER, number, start);
            continue;
        }
        
        switch(source[pos]) {
            case '+': 
                tokens ~= new Token(TokenType.PLUS, "+", pos);
                ++pos;
                break;
            case '-':
                tokens ~= new Token(TokenType.MINUS, "-", pos);
                ++pos;
                break;
            case '*': 
                tokens ~= new Token(TokenType.MUL, "*", pos);
                ++pos;
                break;
            case '/':
                tokens ~= new Token(TokenType.DIV, "/", pos);
                ++pos;
                break;
            case '(': 
                tokens ~= new Token(TokenType.LPAREN, "(", pos);
                ++pos;
                break;
            case ')':
                tokens ~= new Token(TokenType.RPAREN, ")", pos);
                ++pos;
                break;
            default:
                throw new Exception(format("Unexpected character: %s at position %s", source[pos], pos));
        }
    }
    return tokens;
}

int getPrecedence(TokenType op) {
    switch(op) {
        case TokenType.PLUS, TokenType.MINUS:
            return 1;
        case TokenType.MUL, TokenType.DIV:
            return 2;
        default:
            return 0;
    }
}

Token[] infixToPostfix(Token[] infixTokens) {
    Token[] output;
    Token[] operatorStack;
    
    foreach(token; infixTokens) {
        if(token.type == TokenType.NUMBER) {
            output ~= token;
        } else if(token.type == TokenType.LPAREN) {
            operatorStack ~= token;
        } else if(token.type == TokenType.RPAREN) {
            while(operatorStack.length > 0 && operatorStack[$-1].type != TokenType.LPAREN) {
                output ~= operatorStack[$-1];
                operatorStack.length -= 1;
            }

            if(operatorStack.length > 0) {
                operatorStack.length -= 1;
            }
        } else {
            while(operatorStack.length > 0 && getPrecedence(operatorStack[$-1].type) >= getPrecedence(token.type) && operatorStack[$-1].type != TokenType.LPAREN) {
                output ~= operatorStack[$-1];
                operatorStack.length -= 1;
            }
            operatorStack ~= token;
        }
    }
    
    while(operatorStack.length > 0) {
        output ~= operatorStack[$-1];
        operatorStack.length -= 1;
    }
    
    return output;
}

int evaluatePostfix(Token[] tokens) {
    int[] stack;

    foreach(token; tokens) {
        if(token.type == TokenType.NUMBER) {
            stack ~= to!int(token.token);
        } else {
             enforce(stack.length >= 2, "Not enough operands");
            
            int b = stack[$-1];
            int a = stack[$-2];
            stack.length -= 2;
            
            switch(token.type) {
                case TokenType.PLUS:
                    stack ~= a + b;
                    break;
                case TokenType.MINUS:
                    stack ~= a - b;
                    break;
                case TokenType.MUL:
                    stack ~= a * b;
                    break;
                case TokenType.DIV:
                    enforce(b != 0, "Division by zero!");
                    stack ~= a / b;
                    break;
                default:
                    throw new Exception("Unknown operator");
            }
        }
    }
    
    enforce(stack.length == 1, "Invalid expression");
    return stack[0];
}

void main() {
    writeln("TurboCalculator 1.0v");
    while(true) {
        write(">>> ");
        string command = readln();
        Token[] tokens = tokenize(command);
        Token[] postfixTokens = infixToPostfix(tokens);
        int result = evaluatePostfix(postfixTokens);
        writeln(result);
    }
}