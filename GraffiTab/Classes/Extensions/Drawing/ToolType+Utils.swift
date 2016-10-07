//
//  ToolType+Utils.swift
//  GraffiTab
//
//  Created by Georgi Christov on 07/10/2016.
//  Copyright © 2016 GraffiTab. All rights reserved.
//

import UIKit

extension ToolType {

    func icon() -> UIImage! {
        var name = ""
        
        switch self {
            case PEN:
                name = "t_pen"
                break
            case PENCIL:
                name = "t_pencil"
                break
            case MARKER:
                name = "t_highlighter"
                break
            case SPRAY:
                name = "t_spray"
                break
            case CHALK:
                name = "t_chalk"
                break
            case BRUSH:
                name = "t_brush"
                break
            case ERASER:
                name = "t_eraser"
                break
            default:
                break
        }
        
        return UIImage(named: name)
    }
}
